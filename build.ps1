$path = $MyInvocation.MyCommand.Path;

Get-ChildItem -Path @(Get-Item($path))[0].Directory.FullName -Filter .latex.build -Recurse -ErrorAction SilentlyContinue -Force | ForEach-Object {
    $config = $_;

    $c = Get-Content $_.FullName;

    Write("LaTeX build configuration file found: '$($_.FullName)'");
    Add-AppveyorMessage -Message "LaTeX build configuration file found" -Details "Config file: '$($config.FullName)'";

    $build_command = $null;
    $build_doc = $null;
    $build_dir = $null;

    $c | ForEach-Object {
        $m = [Regex]::Match($_, "^\s*latex-build-command\s*=\s*(.*)$");
        if ($m.Success) {
            $build_command = $m.Groups[1].Value;
        }
        $m = [Regex]::Match($_, "^\s*latex-build-doc\s*=\s*(.*)$");
        if ($m.Success) {
            $build_doc = $m.Groups[1].Value;
        }
        $m = [Regex]::Match($_, "^\s*latex-build-dir\s*=\s*(.*)$");
        if ($m.Success) {
            $build_dir = $m.Groups[1].Value;
        }
    }

    if ($build_command -eq $null) {
        Write("    No explicit build command specified, use env");
        $build_command = $Env:LATEX_BUILD_COMMAND;
        if ($build_command -eq $null) {
            Write("    No build command found, stop processing this configuration");
            Add-AppveyorMessage -Message "No build command found, stop processing this configuration" -Details "Config file: '$($config.FullName)'" -Category "Warning";
            return;
        }
    }

    $build_dir_specified = 1;
    if ($build_dir -eq $null) {
        Write("    No build directory specified, use doc directory");
        $build_dir = Get-Item($config).Directory;
        $build_dir_specified = 0;
    }

    if ($build_doc -eq $null) {
        Write("    No document to build specified, use first '.tex' file found in '$($build_dir)'");
        $f = Get-ChildItem -Path $build_dir -Filter *.tex -Recurse -ErrorAction SilentlyContinue -Force;
        if (@($f)[0] -ne $null) {
            $build_doc = @($f)[0].FullName;
            if ($build_dir_specified -eq 0) {
                $build_dir = @($f)[0].Directory;
            }
        } else {
            Write("    No document to build found, stop processing this configuration");
            Add-AppveyorMessage -Message "No document to build found, stop processing this configuration" -Details "Config file: '$($config.FullName)'" -Category "Warning";
            return;
        }
    }

    $build_artifact = [IO.Path]::ChangeExtension($build_doc, "pdf");

    Write("    Use build command: '$($build_command)'");
    Write("    Use build dir:     '$($build_dir)'");
    Write("    Use build doc:     '$($build_doc)'");
    Write("    Expected artifact: '$($build_artifact)'");

    Add-AppveyorMessage -Message "LaTeX build configuration details" -Details "
Use config file:   '$($config.FullName)'
Use build command: '$($build_command)'
Use build dir:     '$($build_dir)'
Use build doc:     '$($build_doc)'
Expected artifact: '$($build_artifact)'";

    cd "$($build_dir)";
    Invoke-Expression -Command:"cmd.exe /c $($build_command) '$($build_doc)'";
    cd @(Get-Item($path))[0].Directory.FullName;

    # Build again on error for compatibility with some LaTeX packages, e.g. beamer
    if ((Test-Path($build_artifact)) -ne $True) {
        Add-AppveyorMessage -Message "No artifact found, try agan" -Details "Config file: '$($config.FullName)'" -Category "Warning";
        
        cd "$($build_dir)";
        Invoke-Expression -Command:"cmd.exe /c $($build_command) '$($build_doc)'";
        cd @(Get-Item($path))[0].Directory.FullName;
        
        if ((Test-Path($build_artifact)) -ne $True) {
            Add-AppveyorMessage -Message "No artifact found, stop processing this configuration" -Details "Config file: '$($config.FullName)'" -Category "Warning";
            return;
        }
    }

    $rel_build_artifact = $build_artifact | Resolve-Path -Relative;
    Push-AppveyorArtifact "$($rel_build_artifact)" -FileName "$($rel_build_artifact)";
}
