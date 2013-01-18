﻿Properties {
    $basedir = Get-Location
    $outputdir = Join-Path $basedir 'Build'
    $quotedoutputdir = '"' + $outputdir + '"'
    $framework = 4.0
    $v4_net_version = (ls "$env:windir\Microsoft.NET\Framework\v$framework*").Name
    $msbuildpath = "$env:windir\Microsoft.NET\Framework\$v4_net_version\MsBuild.exe"
}

include .\utils.ps1

Task Default -depends Test

Task Clean {
    if(Test-Path $outputdir)
    {
        Remove-Item -Path $outputdir -Recurse -Force
    }
}

Task SetVersion {
	$version = Get-Version
	$SolutionVersion = Generate-Assembly-Info $version["version"] $version["commit"] $version["dirty"]
	$SolutionVersion > SolutionVersion.cs 
}

Task Build -depends Clean, SetVersion {
    if(!$solution)
    {
        $solution = Get-Item -Path .\ -Include *.sln
    }
    Write-Warning $quotedoutputdir
    Exec { 
       & $msbuildpath $solution "/p:OutDir=$quotedoutputdir\"
    }
}



Task Test -depends Build {
    
    $nunit = (Get-ChildItem 'nunit-console.exe' -Path $basedir -Recurse).FullName
    $assemblies = @(Get-ChildItem *.Tests.dll -Path $outputdir | %{ $_.FullName} )
    
	if($assemblies)    
    {
        $linearAsms = [System.String]::Join(" ", $assemblies)
		Write-Warning $linearAsms
		Write-Warning $nunit
        Exec {
           & $nunit $linearAsms /domain:single
        }
    }
    
}