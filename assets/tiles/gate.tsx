<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="gate" tilewidth="64" tileheight="52" tilecount="5" columns="1" objectalignment="bottom">
 <tileoffset x="16" y="0"/>
 <grid orientation="orthogonal" width="64" height="32"/>
 <properties>
  <property name="Solid" type="bool" value="true"/>
 </properties>
 <image source="gate.png" width="64" height="260"/>
 <tile id="0">
  <objectgroup draworder="index" id="2">
   <object id="2" x="10" y="36">
    <polygon points="3,-1 1,-5 7,-5 42,13 43,16 35,16"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="0" duration="50"/>
   <frame tileid="1" duration="50"/>
   <frame tileid="2" duration="50"/>
   <frame tileid="3" duration="50"/>
  </animation>
 </tile>
</tileset>
