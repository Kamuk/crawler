##############################################################################
#	
##############################################################################

@CLASS
AMCriteria

@OPTIONS
locals

@BASE
SqlCriteria



##############################################################################
@create[uParam]
	$self._join_association[^hash::create[]]
	$self._include[^hash::create[]]

	^BASE:create[$uParam]
#end @create[]



##############################################################################
@merge[*args]
	^args.foreach[k;criteria]{
		^if(^is_array[$criteria]){
			^criteria.foreach[j;criteria]{
				^self.merge[$criteria]
			}
		}{
			^self._merge[$criteria]
		}
	}
	$result[]
#end @merge[]



##############################################################################
@_merge[uCriteria]
	^switch[$uCriteria.CLASS_NAME]{
		^case[hash]{
			$criteria[^hash::create[$uCriteria]]
		
			^if(^criteria.contains[join_table]){
				^self.join_table[$criteria.join_table]
				$criteria.join_table[]
			}
			^if(^criteria.contains[join]){
				^self.join[$criteria.join]
				$criteria.join[]
			}
			^if(^criteria.contains[include]){
				^self.include[$criteria.include]
			}

			^BASE:merge[$criteria]
		}
		
		^case[AMCriteria]{
#			^BASE:merge[$uCriteria]

			^rem{ *** FIX: use BASE:merge но ошибка из-за вызова join из SqlCriteria сного в AMCriteria *** }
			^self.distinct[$uCriteria._distinct]
			^self.column[$uCriteria._column]
			^if(def $uCriteria._from.table || def $uCriteria._from.alias){
				^self.from[$uCriteria._from]
			}
			^BASE:join[$uCriteria._join]
			^self.condition[$uCriteria._condition]
			^self.group[$uCriteria._group]
			^self.having[$uCriteria._having]
			^self.order[$uCriteria._order]
			^if($uCriteria._limit){
				^self.limit[$uCriteria._limit]
			}
			^if($uCriteria._offset){
				^self.offset[$uCriteria._offset]
			}

			^self.join[$uCriteria._join_association]
			^self.include[$uCriteria._include]
		}
		
		^case[SqlCriteria]{
#			^BASE:merge[$uCriteria]

			^rem{ *** FIX: use BASE:merge но ошибка из-за вызова join из SqlCriteria сного в AMCriteria *** }
			^self.distinct[$uCriteria._distinct]
			^self.column[$uCriteria._column]
			^if(def $uCriteria._from.table || def $uCriteria._from.alias){
				^self.from[$uCriteria._from]
			}
			^BASE:join[$uCriteria._join]
			^self.condition[$uCriteria._condition]
			^self.group[$uCriteria._group]
			^self.having[$uCriteria._having]
			^self.order[$uCriteria._order]
			^if($uCriteria._limit){
				^self.limit[$uCriteria._limit]
			}
			^if($uCriteria._offset){
				^self.offset[$uCriteria._offset]
			}
		}
		
		^case[ActiveRelation]{
			^self.merge[$uCriteria.CRITERIA]
		}
		
		^case[SqlCondition;string;void]{
			^BASE:merge[$uCriteria]
		}
		
		^case[DEFAULT]{
			^throw_inspect[$uCriteria.CLASS_NAME]
			^BASE:merge[$uCriteria]
		}
	}

	$result[]
#end @merge[]



##############################################################################
@join_table[uName;hParam]
	^BASE:join[$uName;$hParam]
	$result[]
#end @join_table[]



##############################################################################
@join[uName;uParam]
	^switch[$uName.CLASS_NAME]{
		^case[table]{
			^throw_inspect[$uName]
			^self._join_association.join[$uName]
		}
		
		^case[hash]{
			^rem{ *** FIX: hash of join by alias, not by name *** }
			^uName.foreach[alias;params]{
				^self.join[$alias;$params]
			}
		}
		
		^case[DEFAULT]{
			$join[^uName.match[\s][gi]{}]

			^if(def $join){
				$join[^join.split[,;lv;alias]]

				^if($join == 1){
					^if($self._join_association.[$join.alias]){
						^throw_inspect[$join]
						^throw[parser.runtime;join;same join alrady specify]
					}
				
					^switch[$uParam.CLASS_NAME]{
						^case[hash]{
							$self._join_association.[$join.alias][
								$.type[$uParam.type]
								$.name[^if(def $uParam.name){$uParam.name}{$join.alias}]
								$.condition[^SqlCondition::create[]]
							]
							^self._join_association.[$join.alias].condition.add[$uParam.condition]
						}

						^case[DEFAULT]{
							$self._join_association.[$join.alias][
								$.name[$join.alias]
								$.condition[^SqlCondition::create[]]
							]
						}
					}
				}{
					^join.menu{^self.join[$join.alias]}	
				}
			}
		}
	}

	$result[]
#end @join[]



##############################################################################
@include[uName;hParam]
	^switch[$uName.CLASS_NAME]{
		^case[void;bool]{}

		^case[table]{
			^uName.menu{
				^self.include[$uName.name]
			}
		}
		
		^case[hash]{
			^uName.foreach[name;params]{
				^if($self._include.[$name]){
					^throw[parser.runtime;include;same include alrady spacify]
				}
				$self._include.[$name][$params]
			}
		}

		^case[string]{
			$includes[^uName.match[\s][gi]{}]
			$includes[^includes.split[,;lv;name]]
			^if($includes > 1){
				^self.include[$includes]
			}{
				^self.include[
					$.[$includes.name][$hParam]
				]
			}
		}

		^case[DEFAULT]{
			^throw[parser.runtime;include;not supported format $uName.CLASS_NAME]
		}
	}

	$result[]
#end @include[]



##############################################################################
@print_join[]
	^throw_inspect[$self._join_association]
#end @print_join[]
