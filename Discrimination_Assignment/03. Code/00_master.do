/******************************************************************************
File: 00_master.do
Purpose: This is a do file, which sets the working directory of the respective authors. Please make sure you run this do file first before working on the rest of the do-files.
Names: Aftab, Bishmay, Manya
******************************************************************************/

clear all
macro drop all
set more off

********************* Please set your directory ********************************

* global dir " " // please uncomment this and add the path directory here (example given below)







global dir "/Users/bishmaybarik/Library/CloudStorage/OneDrive-ShivNadarInstitutionofEminence/Discrimination_Assignment_ABM" // Bishmay's Directory

* global dir "C:/Users/mp978/OneDrive - Shiv Nadar Institution of Eminence/Discrimination_Assignment" // Manya's Directory

* global dir "C:/Users/Admin/OneDrive - Shiv Nadar Institution of Eminence/Discrimination_Assignment" // Manya's Directory (laptop)

* global dir "/Users/Aftab/Library/CloudStorage/OneDrive-SharedLibraries-ShivNadarInstitutionofEminence/Bishmay Barik - Discrimination_Assignment" // Aftab's Directory

* Setting the sub-folders

global raw "$dir/01. Raw"
global output "$dir/02. Output"
global latex "$dir/04. Latex"

* Setting sub-sub folders

global figure "$latex/Figures"

