require 'CardUtility'

CardAnalyzer = class('CardAnalyzer')

function CardAnalyzer:ctor(pokeCards)
  self.pokeCards = pokeCards
  self.pokeInfos = CardUtility.getPokeCardsInfo(pokeCards)
  self.bombsInfos = CardUtility.getBombsInfos(self.pokeInfos)
  self.pairsInfos = CardUtility.getPairsInfos(self.pokeInfos)
  self.threesInfos = CardUtility.getThreesInfos(self.pokeInfos)
  self.singlesInfos = CardUtility.getSinglesInfos(self.pokeInfos)
  self.rocketInfos = CardUtility.getRocketInfos(self.pokeInfos)
end

function CardAnalyzer:dump(level)
  level = level or 3
  dump(self.pokeInfos, 'pokeInfos', false, level)
  dump(self.rocketInfos, 'rocketInfos', false, level)
  dump(self.bombsInfos, 'bombsInfos', false, level)
  dump(self.threesInfos, 'threesInfos', false, level)
  dump(self.pairsInfos, 'pairsInfos', false, level)
  dump(self.singlesInfos, 'singlesInfos', false, level)
end