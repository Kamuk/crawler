##############################################################################
@num_decline[num;nominative;genitive_singular;genitive_plural]
^if($num > 10 && (($num % 100) \ 10) == 1){
        $result[$genitive_plural]
}{
        ^switch($num % 10){
                ^case(1){$result[$nominative]}
                ^case(2;3;4){$result[$genitive_singular]}
                ^case(5;6;7;8;9;0){$result[$genitive_plural]}
        }
}
#end @num_decline[]



##############################################################################
@num_format_sign[dValue;sFormat]
	$result[^if($dValue >= 0){+}{-}^eval(^math:abs($dValue))[$sFormat]]
#end @num_format_sign[]
