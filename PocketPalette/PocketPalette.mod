<?xml version="1.0" encoding="UTF-8"?>
<ModuleFile xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <UiMod name="Pocket Palette" version="1.1" date="04/07/2020" >
        
        <Author name="Eibon" email="" />
        <Description text="Pocket Palette inspired by DyePreview. Show the Pocket Palette window using the chat command /PP" />
        <VersionSettings gameVersion="1.4.0" windowsVersion="1.0" savedVariablesVersion="1.1" />

        <Dependencies>
            <Dependency name="EA_AbilitiesWindow" />
            <Dependency name="EA_CareerResourcesWindow" />
            <Dependency name="EA_MoraleWindow" />
            <Dependency name="EASystem_Utils" />
            <Dependency name="EASystem_WindowUtils" />
            <Dependency name="EASystem_Tooltips" />
            <Dependency name="EATemplate_DefaultWindowSkin" />
            <Dependency name="EATemplate_Icons" />
            <Dependency name="EA_CharacterWindow" />
            <Dependency name="LibSlash" />
        </Dependencies>

        <Files>
            <File name="PocketPalette.lua" />
			<File name="PocketPalette.xml" />
            <File name="PocketPalette.csv" />
        </Files>
        
        <OnInitialize>
            <CallFunction name="PP.Initialize" />
            <!--
            <CreateWindow name="DevBarActivator" show="true" />
            -->
        </OnInitialize>
        <OnUpdate>
        </OnUpdate>

        <SavedVariables>
			<SavedVariable name="PP.settings.persistent" global="false" />
            <SavedVariable name="PP.settings.items" global="false" />
		</SavedVariables>

        <OnUpdate />
        <OnShutdown />
    </UiMod>
</ModuleFile>
