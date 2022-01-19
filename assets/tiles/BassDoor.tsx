<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.5.0" name="BassDoor" tilewidth="33" tileheight="56" tilecount="4" columns="4">
 <image source="BassDoor.png" width="132" height="56"/>
 <tile id="0">
  <objectgroup draworder="index" id="2">
   <object id="1" x="-3" y="44">
    <polygon points="0,0 33,18 38,13 3,-6 -1,-1"/>
   </object>
  </objectgroup>
 </tile>
 <tile id="1">
  <animation>
   <frame tileid="0" duration="250"/>
   <frame tileid="1" duration="250"/>
   <frame tileid="2" duration="250"/>
   <frame tileid="3" duration="1000"/>
  </animation>
 </tile>
</tileset>
