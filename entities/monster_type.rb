module YugiohData
  module Entities
    class MonsterType < ActiveRecord::Base
      module Types
        AQUA = 'Aqua'
        BEAST = 'Beast'
        BEAST_WARRIOR = 'Beast-Warrior'
        CREATOR_GOD = 'Creator God'
        CYBERSE = 'Cyberse'
        DINOSAUR = 'Dinosaur'
        DIVINE_BEAST = 'Divine-Beast'
        DRAGON = 'Dragon'
        EFFECT = 'Effect'
        FAIRY = 'Fairy'
        FIEND = 'Fiend'
        FISH = 'Fish'
        FLIP = 'Flip'
        FUSION = 'Fusion'
        GEMINI = 'Gemini'
        INSECT = 'Insect'
        LINK = 'Link'
        MACHINE = 'Machine'
        NORMAL = 'Normal'
        PENDULUM = 'Pendulum'
        PLANT = 'Plant'
        PSYCHIC = 'Psychic'
        PYRO = 'Pyro'
        REPTILE = 'Reptile'
        RITUAL = 'Ritual'
        ROCK = 'Rock'
        SEA_SERPENT = 'Sea Serpent'
        SKILL = 'Skill' # Doesn't really count
        SPELLCASTER = 'Spellcaster'
        SPIRIT = 'Spirit'
        SYNCHRO = 'Synchro'
        THUNDER = 'Thunder'
        TOON = 'Toon'
        TUNER = 'Tuner'
        UNION = 'Union'
        WARRIOR = 'Warrior'
        WINGED_BEAST = 'Winged Beast'
        WYRM = 'Wyrm'
        XYZ = 'Xyz'
        ZOMBIE = 'Zombie'
      end

      self.table_name = 'MonsterType'
    end
  end
end
