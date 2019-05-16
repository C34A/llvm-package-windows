@echo off

:: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

:: delete unnecessary packages

dir \

rd /S /Q "c:\cygwin"
rd /S /Q "c:\cygwin64"
rd /S /Q "c:\winddk"
rd /S /Q "c:\mingw"
rd /S /Q "c:\mingw-w64"
rd /S /Q "c:\qt"

:: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

:: get rid of annoying Xamarin build warnings

if exist "c:\Program Files (x86)\MSBuild\14.0\Microsoft.Common.targets\ImportAfter\Xamarin.Common.targets" (
	del "c:\Program Files (x86)\MSBuild\14.0\Microsoft.Common.targets\ImportAfter\Xamarin.Common.targets"
)

if exist "c:\Program Files (x86)\MSBuild\4.0\Microsoft.Common.targets\ImportAfter\Xamarin.Common.targets" (
	del "c:\Program Files (x86)\MSBuild\4.0\Microsoft.Common.targets\ImportAfter\Xamarin.Common.targets"
)

:: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

:: download LLVM

appveyor DownloadFile %LLVM_DOWNLOAD_URL% -FileName %APPVEYOR_BUILD_FOLDER%\%LLVM_DOWNLOAD_FILE%
7z x -y %APPVEYOR_BUILD_FOLDER%\%LLVM_DOWNLOAD_FILE% -o%APPVEYOR_BUILD_FOLDER%
7z x -y %APPVEYOR_BUILD_FOLDER%\llvm-%LLVM_VERSION%.src.tar -o%APPVEYOR_BUILD_FOLDER%
ren %APPVEYOR_BUILD_FOLDER%\llvm-%LLVM_VERSION%.src llvm

:: on Debug builds:
:: - patch CMakeLists.cmake to always build and install llvm-config
:: - patch AddLLVM.cmake to also install PDBs on Debug builds

if "%CONFIGURATION%" == "Debug" (
	echo "set_target_properties(llvm-config PROPERTIES EXCLUDE_FROM_ALL FALSE)" >> llvm/CMakeLists.cmake
	echo "install(TARGETS llvm-config RUNTIME DESTINATION bin)" >> llvm/CMakeLists.cmake
	perl patch-add-llvm.pl llvm\cmake\modules\AddLLVM.cmake
)

:: . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

:: download Clang

:: appveyor DownloadFile %CLANG_DOWNLOAD_URL% -FileName %APPVEYOR_BUILD_FOLDER%\%CLANG_DOWNLOAD_FILE%
:: 7z x -y %APPVEYOR_BUILD_FOLDER%\%CLANG_DOWNLOAD_FILE% -o%APPVEYOR_BUILD_FOLDER%
:: 7z x -y %APPVEYOR_BUILD_FOLDER%\cfe-%LLVM_VERSION%.src.tar -o%APPVEYOR_BUILD_FOLDER%
:: ren %APPVEYOR_BUILD_FOLDER%\cfe-%LLVM_VERSION%.src clang
