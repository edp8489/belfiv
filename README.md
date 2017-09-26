# README

BELFIV program

Transcribed from MSFC-DWG-20502540
"Assessment of Flexible Lines for Flow Induced Vibration"

# Installation

## DOS, Using IBM PROFORT compiler through DOSBox emulator
- Launch DOSBox
- Mount belfiv main directory as C:
> `mount C: Drive:\path\to\belfiv\folder`

- Change to build directory
> `C:`
> `cd build`

- (Optional) Make new folder for build
> `mkdir 20170925`

- Compile belfiv object
> `..\..\util\profort\profort.exe ..\..\src\belfiv.f`

- Link object file to .exe 
> `..\..\util\profort\link.exe belfiv.obj`

- Follow prompts inside linker [default option]
> `Run File [BELFIV.EXE]: FILENAME.EXE`
> `List File [NUL.MAP]: <hit enter>`
> `Libraries [.LIB]: ..\..\util\profort\profort.lib`

## Using gcc on modern systems
* in work *
- From main belfiv directory
> `gfortran -std=gnu -ffixed-form -ffixed-line-length-80  -Wextra -Wall -pedantic src/belfiv.f -o bin/belfiv.bin`