<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.2" name="Secret Area Warp" tilewidth="80" tileheight="43" tilecount="3" columns="3" objectalignment="top">
 <tileoffset x="0" y="-8"/>
 <image source="Secret_Area_Warp.png" width="240" height="43"/>
 <tile id="0">
  <objectgroup draworder="index" id="2">
   <object id="1" x="17" y="21">
    <polygon points="0,0 19,-10 27,-10 47,0 47,1 25,14 21,14 1,4"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="0" duration="2000"/>
   <frame tileid="1" duration="2000"/>
   <frame tileid="2" duration="2000"/>
   <frame tileid="1" duration="2000"/>
  </animation>
 </tile>
</tileset>
