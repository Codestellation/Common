﻿function Get-Version
{
	$gitTag = git describe --dirty
	#0.0-1-g3655
	#0.0-1-g3655-dirty
	$tokens = $gitTag.Split('-')
	
	$version = $tokens[0]

	if($gitTag.Contains("dirty"))
	{
		$dirty = "dirty"
	}
	
	if($tokens.length -ge 3)
	{
		$commitCount = $tokens[1]
		$version = "$version.$commitCount"
		$commit = $tokens[2]
	}
	if(!$commit)
	{
		$commit = (git log --oneline -1).Split(' ')[0]
	}
	
	return @{ version = $version; commit = $commit; dirty = $dirty  }
}

function Generate-Assembly-Info
{
	param(
		[string]$version,
		[string]$commit,
		[string]$dirty
	)

	$asmInfoVersion = "$version $commit"
	if($dirty)
	{
		$asmInfoVersion += " $dirty"
	}
	$asmInfo = "using System;
	
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

[assembly: AssemblyCompanyAttribute(""Codestellation"")]
[assembly: AssemblyCopyrightAttribute(""Copyright (c) 2012-2013 Codestellation"")]
[assembly: AssemblyVersionAttribute(""$version"")]
[assembly: AssemblyInformationalVersionAttribute(""$asmInfoVersion"")]
[assembly: AssemblyFileVersionAttribute(""$version"")]"

	return $asmInfo;
}