local PokecardPickAI = class('PokecardPickAI')

function PokecardPickAI:findValidCard(pickedPokecards, tipPokecards)
  -- 两张以下的，直接返回
  local count = #pickedPokecards
  if count <= 2 then
    return pickedPokecards
  end

  if count == 3 then
  end

end

return PokecardPickAI