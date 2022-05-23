local Preloader = {}

local asset_paths = {
  "/server/assets/bots/blur.png",
  "/server/assets/bots/blur.animation",
  "/server/assets/bots/explosion.png",
  "/server/assets/bots/explosion.animation",
  "/server/assets/bots/paralyze.png",
  "/server/assets/bots/paralyze.animation",
  "/server/assets/bots/recover.png",
  "/server/assets/bots/recover.animation",
  "/server/assets/bots/item.png",
  "/server/assets/bots/item.animation",
  "/server/assets/sound effects/hurt.ogg",
  "/server/assets/sound effects/explode.ogg",
  "/server/assets/sound effects/paralyze.ogg",
  "/server/assets/sound effects/recover.ogg",
}

function Preloader.add_asset(asset_path)
  asset_paths[#asset_paths+1] = asset_path
end

function Preloader.update(area_id)
  for _, asset_path in ipairs(asset_paths) do
    Net.provide_asset(area_id, asset_path)
  end
end

return Preloader
