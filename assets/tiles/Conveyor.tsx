<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.0" name="Conveyor" tilewidth="64" tileheight="32" tilecount="6" columns="1" objectalignment="top">
 <image source="Conveyor.png" width="64" height="64"/>
 <tile id="0" type="Conveyor">
  <properties>
   <property name="Direction" value="Up Left"/>
   <property name="Sound Effect" value="/server/assets/dir_tile.ogg"/>
   <property name="Speed" value="6"/>
  </properties>
 </tile>
 <tile id="1" type="Conveyor">
  <properties>
   <property name="Direction" value="Down Left"/>
   <property name="Sound Effect" value="/server/assets/dir_tile.ogg"/>
   <property name="Speed" value="6"/>
  </properties>
 </tile>
 <tile id="5">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="16">
    <polygon points="0,0 64,0 64,16 0,16"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="6">
  <objectgroup draworder="index" id="2">
   <object id="1" x="32" y="0">
    <polygon points="0,0 -32,0 -32,32 0,32"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="7">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="16">
    <polygon points="0,0 0,-16 64,-16 64,0"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="8">
  <objectgroup draworder="index" id="2">
   <object id="1" x="32" y="32">
    <polygon points="0,0 0,-32 32,-32 32,0"/>
   </object>
  </objectgroup>
 </tile>
</tileset>
