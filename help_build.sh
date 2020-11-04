#!/bin/sh

echo "Building help index."
hiutil -I lsm -vvvCaf ./Conscious/Assets/Costumemaster.help/Contents/Resources/English.lproj/English.lproj.helpindex -s en -l en ./Conscious/Assets/Costumemaster.help/Contents/Resources/English.lproj/
hiutil -I lsm -vFf ./Conscious/Assets/Costumemaster.help/Contents/Resources/English.lproj/English.lproj.helpindex
echo "Building help Spotlight index."
hiutil -I corespotlight -vvvCaf ./Conscious/Assets/Costumemaster.help/Contents/Resources/English.lproj/English.lproj.cshelpindex -s en -l en ./Conscious/Assets/Costumemaster.help/Contents/Resources/English.lproj/
hiutil -I corespotlight -vFf ./Conscious/Assets/Costumemaster.help/Contents/Resources/English.lproj/English.lproj.cshelpindex
