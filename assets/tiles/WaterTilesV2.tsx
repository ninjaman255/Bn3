<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.5" tiledversion="1.7.0" name="WaterTilesV2" tilewidth="64" tileheight="44" tilecount="36" columns="9">
 <tileoffset x="0" y="12"/>
 <image source="WaterTilesV2.png" width="576" height="176"/>
 <tile id="0">
  <objectgroup draworder="index" id="2">
   <object id="2" x="0" y="18">
    <polygon points="0,-2 32,-18 64,-2 32,14"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="0" duration="300"/>
   <frame tileid="1" duration="300"/>
   <frame tileid="2" duration="300"/>
   <frame tileid="3" duration="300"/>
   <frame tileid="4" duration="300"/>
   <frame tileid="5" duration="300"/>
   <frame tileid="6" duration="300"/>
   <frame tileid="7" duration="300"/>
  </animation>
 </tile>
 <tile id="1">
  <objectgroup draworder="index" id="2">
   <object id="2" x="0" y="18">
    <polygon points="0,-2 32,-18 64,-2 32,14"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="4" duration="300"/>
   <frame tileid="5" duration="300"/>
   <frame tileid="6" duration="300"/>
   <frame tileid="7" duration="300"/>
   <frame tileid="0" duration="300"/>
   <frame tileid="1" duration="300"/>
   <frame tileid="2" duration="300"/>
   <frame tileid="3" duration="300"/>
  </animation>
 </tile>
 <tile id="9">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="18">
    <polygon points="0,-2 32,-18 64,-2 32,14"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="9" duration="300"/>
   <frame tileid="10" duration="300"/>
   <frame tileid="11" duration="300"/>
   <frame tileid="12" duration="300"/>
   <frame tileid="13" duration="300"/>
   <frame tileid="14" duration="300"/>
   <frame tileid="15" duration="300"/>
   <frame tileid="16" duration="300"/>
  </animation>
 </tile>
 <tile id="10">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="18">
    <polygon points="0,-2 32,-18 64,-2 32,14"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="13" duration="300"/>
   <frame tileid="14" duration="300"/>
   <frame tileid="15" duration="300"/>
   <frame tileid="16" duration="300"/>
   <frame tileid="9" duration="300"/>
   <frame tileid="10" duration="300"/>
   <frame tileid="11" duration="300"/>
   <frame tileid="12" duration="300"/>
  </animation>
 </tile>
 <tile id="18">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="18">
    <polygon points="0,-2 32,-18 64,-2 32,14"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="18" duration="300"/>
   <frame tileid="19" duration="300"/>
   <frame tileid="20" duration="300"/>
   <frame tileid="21" duration="300"/>
   <frame tileid="22" duration="300"/>
   <frame tileid="23" duration="300"/>
   <frame tileid="24" duration="300"/>
   <frame tileid="25" duration="300"/>
  </animation>
 </tile>
 <tile id="19">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="18">
    <polygon points="0,-2 32,-18 64,-2 32,14"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="22" duration="300"/>
   <frame tileid="23" duration="300"/>
   <frame tileid="24" duration="300"/>
   <frame tileid="25" duration="300"/>
   <frame tileid="18" duration="300"/>
   <frame tileid="19" duration="300"/>
   <frame tileid="20" duration="300"/>
   <frame tileid="21" duration="300"/>
  </animation>
 </tile>
 <tile id="27">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="18">
    <polygon points="0,-2 32,-18 64,-2 32,14"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="27" duration="300"/>
   <frame tileid="28" duration="300"/>
   <frame tileid="29" duration="300"/>
   <frame tileid="30" duration="300"/>
   <frame tileid="31" duration="300"/>
   <frame tileid="32" duration="300"/>
   <frame tileid="33" duration="300"/>
   <frame tileid="34" duration="300"/>
  </animation>
 </tile>
 <tile id="28">
  <objectgroup draworder="index" id="2">
   <object id="1" x="0" y="18">
    <polygon points="0,-2 32,-18 64,-2 32,14"/>
   </object>
  </objectgroup>
  <animation>
   <frame tileid="31" duration="300"/>
   <frame tileid="32" duration="300"/>
   <frame tileid="33" duration="300"/>
   <frame tileid="34" duration="300"/>
   <frame tileid="27" duration="300"/>
   <frame tileid="28" duration="300"/>
   <frame tileid="29" duration="300"/>
   <frame tileid="30" duration="300"/>
  </animation>
 </tile>
 <wangsets>
  <wangset name="EmptySpaceFillin" type="mixed" tile="0">
   <wangcolor name="" color="#0000ff" tile="-1" probability="1"/>
   <wangcolor name="" color="#00ff00" tile="-1" probability="1"/>
   <wangtile tileid="0" wangid="1,1,1,1,1,1,1,1"/>
   <wangtile tileid="1" wangid="2,2,2,2,2,2,2,2"/>
  </wangset>
 </wangsets>
</tileset>
