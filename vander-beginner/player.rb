class Player
  def play_turn(warrior)
    @warrior = warrior
	catch(:end_turn) { turn }
    @health = health
  end

  def turn
	pivot! if feel.wall?
	walk!(:backward) if look(:backward)[1].captive?
	walk! if look(:backward)[2].enemy?
	rescue!(direction_to_captive?) if direction_to_captive? != nil
	walk! if (health == 20 && look[1].enemy? && feel.empty?) || (health == 20 && look[2].enemy? && look[1].empty? && feel.empty?)
	shoot! if (look[1].enemy? && feel.empty?) || (look[2].enemy? && feel.empty? && look[1].empty?)
	rest! if health < 8 && health >= @health && feel.empty? && feel(:backward).empty?
	walk!(:backward) if health < 8 && health < @health
	attack! if feel.enemy?
	walk!
  end
  
  def initialize
	@health = 20
  end
  
  # Get rid of the warrior.everything
  def method_missing(sym, *args, &block)
    ret = @warrior.send(sym, *args, &block)
	throw :end_turn if sym=~ /!$/
	ret
  end
  
  def direction_to_captive?
	return :forward if feel.captive?
	return :backward if feel(:backward).captive?
	return nil
  end
end
