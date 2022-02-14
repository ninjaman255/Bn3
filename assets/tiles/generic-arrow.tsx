<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="generic-arrow" tilewidth="64" tileheight="32" tilecount="9" columns="1" objectalignment="top">
 <image source="generic-arrow.png" width="64" height="288"/>
 <tile id="1" type="Arrow">
  <properties>
   <property name="Direction" value="Down Right"/>
  </properties>
 </tile>
 <tile id="2" type="Arrow">
  <properties>
   <property name="Direction" value="Down Left"/>
  </properties>
 </tile>
 <tile id="3" type="Arrow">
  <properties>
   <property name="Direction" value="Up Left"/>
  </properties>
 </tile>
 <tile id="4" type="Arrow">
  <properties>
   <property name="Direction" value="Up Right"/>
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
