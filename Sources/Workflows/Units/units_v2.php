<?php



/**
* Name: 				Units
* Description: 	This PHP class object provides several useful functions for retrieving, parsing,
* 							and formatting data to be used with the Alfred 2 - Units.
* Author: 			Thijs de Jong (www.designandsuch.com)
* Revised: 			5/18/2013
* Version:			0.2.2
*
*
* things to do:
*								- improve search result order
*								- make updatable
*								- get data from outside
*								- imrpove currency refresh
*								------- fix category filter 
*/
date_default_timezone_set('utc');
require( 'alfred.flow.0.1.php' );
 
class Units #0
{
	public $alfred; 
	public $functions = array('bundleid','refresh','update','phpversion');
	public $raw_query;
	public $in_val;
	public $in_type;
	public $type_raw;
	public $out_val;
	public $out_type;
	public $spaced;
	public $lib = array();
	public $category;
	public $categories;
	public $catfilter;
	
	public $currency_cache = 'currencies.json';
	public $currency_cache_fallback = 'data/currencies_fallback.json';
	public $currency_source = 'http://themoneyconverter.com/rss-feed/USD/rss.xml';
	public $currency_lib;
	public $currency_date;
	
	public $brain_cache = 'unit_brain.json';
	public $brain;
	
	public $debugging = false;
	
	
	
	
	/**
	 * @param none
	 * @return none
	 */
	function __construct()
	{
		$this->start_debug();
		
		$this->alfred = new Alfredflow();
		$this->populate_lib();
		//$this->populate_currency();
		$this->set_categories();
		$this->set_brain();
		$this->set_currency_lib();
  }
  
  /**
   * main router of the units, a couple things can happen.. 
   * 1. you hit a custom function by keyword
   * 2. you die because there was no input value given
   * 3. you get suggestions for in- or output types
   * 4. you get results based on an input value and one or both unit types
   *
	 * @param $q - the main input
	 * @return none
	 * @echo alfred xml string
	 */
	public function convert($q = null) #1
	{
		$this->read_query($q);
		
		if ( in_array($q,$this->functions,TRUE)): 
			call_user_func(array($this, $q), null);	
		else:
			if((!$q)): 
				$this->show_categories(); //only if query is optional
			else: 
				if(!isset($this->in_type)): 
					if((empty($this->type_raw))&&(!$this->catfilter)): 
							$this->show_categories();
					else: 
							$this->show_type_suggestions('in');
					endif;
				else: 
					if((!isset($this->out_type))&&(!empty($this->type_raw))): 
						$this->show_type_suggestions('out');
					else: 
						$this->get_results();
					endif;
				endif;
			endif;	
		endif;
		
		
		
		$this->show_debug_result();
		echo $this->alfred->toxml();
	}
	
	/* -------------------  READ THE QUERY -------------------- */
	
	/**
	 * read the query string and extract data from it..
	 *
	 * $spaced 			has the query a decending spaced
	 * $in_val 			the value to calculate with
	 * $in_type			the unit of input (km|mi|usd)
	 * $out_typ			the unit of output
	 *
	 * @param (string)
	 * @return none
	 */
	private function read_query($q = '') #2
	{
		$this->raw_query = $q;
		
		$this->spaced = (substr($q,-1)==' ');
		
		if(preg_match("/:(\w*):/", $q, $matches)):
			if(array_key_exists(str_replace(':','',$matches[0]), $this->categories)):
					$this->catfilter = str_replace(':','',$matches[0]);
					$q = str_replace($matches[0],'',$q);
			endif;
		endif;
		
		$qs = explode(' ',$q);
			
		if(isset($qs[0])):
			$this->in_val = $this->extract_float($qs[0]);
			$this->in_type = $this->extract_type($qs[0],true);
			if(!empty($qs[1])):
				if(!isset($this->in_type)):
					$this->in_type = $this->extract_type($qs[1]);
					if(!empty($qs[3])): 
						$this->out_type = $this->extract_type($qs[3]);
					elseif(!empty($qs[2])):
						$this->out_type = $this->extract_type($qs[2]);
					endif;
				else:
					if(!empty($qs[2])):
						$this->out_type = $this->extract_type($qs[2]);
					else:
						$this->out_type = $this->extract_type($qs[1]);
					endif;
				endif;
			endif;
		endif;
	}

	/* -------------------  CATEGORIES -------------------- */
	
	/**
	 * show categories
	 *
	 * @param none
	 * @return none
	 */
	private function set_categories()
	{
		$results = array();
		
		foreach ($this->lib as $unit => $data):
			$results[$data['c']]['count'] += 1;
			$results[$data['c']]['title'] .= $data['dn'].' '; //list of all units
		endforeach;

		$this->categories = $results;
	}
	/**
	 * show categories
	 *
	 * @param none
	 * @return none
	 */
	private function show_categories()
	{
		if(isset($this->categories)):
			foreach ( $this->categories as $category => $data):
				$this->alfred->result(0,0,$category,''.$data['count'].' units','icons/'.str_replace(' ','-',$category).'.png','no',$this->in_val.':'.$category.':');
			endforeach;
		else:
			$this->alfred->result(0,0,'{no categories found}','[debug]','','no'); 
		endif;
	}
	
	/* -------------------  SHOW SUGGESTIONS -------------------- */
	
	/**
	 * gets the lib and orders it by priority
	 *
	 * @param (string) 'in' or 'out'
	 * @return none
	 */ 
	private function show_type_suggestions($for = 'in')
	{
		$results = array();
		$is_for_input = ($for === 'in' ? true : false);
		$q = $this->type_raw;
		$temp_lib = $this->lib;
		
		foreach ($temp_lib as $unit => $data):
		
			$skip_this = false;
			 
			if((!empty($this->catfilter)) && ($this->catfilter !== $data['c'])): //category view..
				$skip_this = true;
			endif;
			
			if((empty($q))&&(!$data['p'])&&(!$this->catfilter)): // no query > only populars
				$skip_this = true;
			endif;
			
			if(($skip_this == false)&&(!$is_for_input)&&($this->lib[$this->in_type]['c'] !== $data['c'])): // output -> no category match for outputs
				$skip_this = true;
			endif;
			
			if(($skip_this == false)&&(!$is_for_input)&&($this->in_type == $unit)): // output -> self to self conversion
				$skip_this = true;
			endif;
			
			$data['pts'] = $data['prio']+$this->brain_val($unit); 
			
			if((!empty($this->type_raw))): //if there is no query no filtering for points... 
			
				if ((!$skip_this)&&(strpos( strtolower($data['r'])  ,  strtolower($this->type_raw)) !== false)):
					
					if 		 (strpos($data['r'],'|'.$this->type_raw.'|')!== false): // 'pipe match' matches a perfect |pipe val|
						$data['pts'] += 10;
					elseif (strpos(strtolower($data['r']),'|'.strtolower($this->type_raw).'|') !== false): // 'case insensitive pipematch' matches a samecase |pipe val|
						$data['pts'] += 7;
					elseif (strpos($data['r'],'|'.$this->type_raw) !== false): // 'left pipe match' 
						$data['pts'] += 4;
					elseif (strpos($data['r'],$this->type_raw.'|') !== false): // 'right pipe match' 
						$data['pts'] += 2;
					else:
						$data['pts'] += 1; // 'rough match' if $q is within the regex at all
					endif;
				else:
					$skip_this = true;
				endif; 
			
			endif;
			
			
			if(!$skip_this): //if they passed all the tests
				$results[$unit] = $data; 
			endif;
				
		endforeach;
		
		# sort by match pts
		$temp_results = $results;
		$points = array();
		foreach ($results as $key => $row):
    $points[$key] = $row['pts'];
		endforeach;
		array_multisort($points, SORT_DESC, $temp_results);
		$results = $temp_results;
		
		
		#2 how to show the suggestion		
		if(empty($results)):
			$error_what = array('that doesn\'t ring a bell','you\'ve got to be kidding me','really?');
			$rand_key = array_rand($error_what);
			if(!$is_for_input):
				$autocomplete = $this->in_val.$this->in_type.' ';
				$this->alfred->result(0,0,''.$this->lib[$this->in_type]['n'].' to '.$this->type_raw.' ?',$error_what[$rand_key],'icons/error.png','no',$autocomplete);
			else:
				$autocomplete = $this->in_val;
				$this->alfred->result(0,0,'what do you mean '.$this->type_raw.'?',$error_what[$rand_key],'icons/error.png','no',$autocomplete);
			endif;
		else:
			foreach ( $results as $unit => $data ):
				$suggestion = ($is_for_input? $this->in_val.$unit.' ' : $this->in_val.$this->in_type.' '.$unit.' ' );
				$a = array(
					'uid' => 'unit_sug_'.$unit,
					'arg' => 0,
					'title' =>  (!$is_for_input? $this->lib[$this->in_type]['n'].' to ' : '').$data['dn'] , //$this->lib[$this->in_type]['n']
					'subtitle' => $data['c'].' '.$unit.' ',
					'icon' => 'icons/'.$data['c'].'.png',
					'valid' => 'no',
					'autocomplete' => $suggestion,
					'type' => null
				);
				$this->alfred->result($a['uid'],$a['arg'],$a['title'],$a['subtitle'],$a['icon'],$a['valid'],$a['autocomplete'],$a['type']);
			endforeach;
		endif;
	}
	
	/* -------------------  GET THE RESULT(S) -------------------- */
	
	/**
	 * @param none
	 * @return none
	 */
	function get_results()
	{
		//if(isset($this->out_type)):
			$this->brain_point($this->in_type);
		//endif;
		
		$this->save_brain();
		
		$output_types = (!isset($this->out_type)? explode('|',$this->lib[$this->in_type]['o']) : array($this->out_type) );

		foreach($output_types as $output_type):
			
			$value = $this->conversion($this->in_type,$output_type,$this->in_val);
			
			$r['title'] = $value.' '.$this->lib[$output_type]['dn'];
			
			if($this->out_type):
				if($this->lib[$output_type]['c'] == 'currency'):
					$r['subtitle'] = 'copy '.$value.' to clipboard  —  exchange rate based on '.strtolower($this->currency_date);
				else:
					$r['subtitle'] = 'copy '.$value.' to clipboard';
				endif;
			else:
				if($this->lib[$output_type]['c'] == 'currency'):
					$r['subtitle'] = $this->in_type.' → '.$output_type;
				else:
					$r['subtitle'] = $this->lib[$this->in_type]['dn'].' '.$this->in_type.' → '.$this->lib[$output_type]['dn'].' '.$output_type.'';
				endif;
			endif;
			
			$a = array(
					'uid' => 'unit_sug_'.$this->in_type, // ?
					'arg' => $value,
					'title' =>  $r['title'],
					'subtitle' => $r['subtitle'],
					'icon' => 'icons/'.$this->lib[$output_type]['c'].'.png',
					'valid' => ($this->out_type? 'yes' : 'no'),
					'autocomplete' => $this->in_val.''.$this->in_type.' '.$output_type.' ',
					'type' => null
				);
				
			$this->alfred->result($a['uid'],$a['arg'],$a['title'],$a['subtitle'],$a['icon'],$a['valid'],$a['autocomplete'],$a['type']);
		endforeach;
	}
  
	/* -------------------  DO VAL > VAL CONVERSIONS -------------------- */
		
	/**
	 * @param (string) 'in' or 'out'
	 * @return val
	 */
	private function conversion($from = null,$to = null,$val = 0)
	{
		//$from = str_replace(' ','',$this->lib[$from]['n']);
		//$to   = str_replace(' ','',$this->lib[$to]['n']);
		
		if($this->lib[$this->in_type]['c'] == 'currency'):
			return $this->currency_conversion($from,$to,$val);
		endif;
		/**
		 * International System of Units
		 */
		 
		//temperature -> base = 1 kelvin
		$k_base				= function($k=0  ){ return $k; };																			//  K  = K
		$base_k				= function($k=0  ){ return round($k,2); };														//  K  = K
		$f_base				= function($f=0  ){ return ($f + 459.67) / 1.8; }; 										//  K  = (°F + 459.67) / 1.8
		$base_f 			= function($k=0  ){ return round($k * 1.8 - 459.67,2); }; 						// °F  = K × 1.8 - 459.67
		$c_base 	 		= function($c=0  ){ return $c + 273.15; }; 														//  K  = °C + 273.15
		$base_c 	 		= function($k=0  ){ return round($k - 273.15,1); };										// °C  = K - 273.15
		$r_base				= function($re=0 ){ return $re * 1.25 + 273.15; }; 										//  K  = °Re × 1.25 + 273.15
		$base_r 			= function($k=0  ){ return round(($k - 273.15) * 0.8,2); }; 					// °Ré = (K - 273.15) × 0.8
		$ro_base			= function($ro=0 ){ return ($ro - 7.5) * 40/21 + 273.15; }; 					//  K  = (°Rø - 7.5) × 40/21 + 273.15
		$base_ro			= function($k=0  ){ return round(($k - 273.15) * 21/40 + 7.5,2); }; 	// °Rø = (K - 273.15) × 21/40 + 7.5
		$ra_base			= function($ra=0 ){ return $ra / 1.8;}; 															//  K  = °Ra / 1.8
		$base_ra		  = function($k=0  ){ return round($k * 1.8,2);}; 											// °Ra = K × 1.8
		$de_base		  = function($de=0 ){ return (373.15 - $de) * 2/3; }; 									//  K  = (373.15 - °De) × 2/3
		$base_de		  = function($k=0  ){ return round((373.15 - $k) * 3/2,2); }; 					// °De = (373.15 - K) × 3/2									
		//length -> base = 1 meter
		//length : metric
		$Gm_base			= function($k=0  ){ return $k  * 1000000000; };							// M  = Km * 1000000000
		$base_Gm			= function($m=0  ){ return $m  / 1000000000; };							// Km = M / 1000000000
		$Mm_base			= function($k=0  ){ return $k  * 1000000; };								// M  = Km * 1000000 
		$base_Mm			= function($m=0  ){ return $m  / 1000000; };								// Km = M / 1 000 000
		$km_base			= function($k=0  ){ return $k  * 1000; };										// M  = Km * 1000
		$base_km			= function($m=0  ){ return $m  / 1000; };										// Km = M / 1000
		$hm_base			= function($hm=0 ){ return $hm * 100;};											// m  = hm / 100
		$base_hm			= function($m=0  ){ return $m  / 100;};											// hm = m * 100
		$dam_base			= function($dm=0 ){ return $dm * 10;};											// m  = hm / 10
		$base_dam			= function($m=0  ){ return $m  / 10;};											// hm = m * 10
		$m_base				= function($m=0  ){ return $m; };	 													// M  = M
		$base_m				= function($m=0  ){ return $m; };														// M  = M
		$dm_base 			= function($dm=0 ){ return $dm / 10;};							  			// dm = m /10
		$base_dm			= function($m=0  ){ return $m  * 10;};											// m  = dm * 10
		$cm_base			= function($cm=0 ){ return $cm / 100;};											// M  = Cm * 100
		$base_cm			= function($m=0  ){ return $m  * 100;};											// M  = Cm / 100
		$mm_base			= function($mm=0 ){ return $mm / 1000;};										// m  = mm / 1000
		$base_mm			= function($m=0  ){ return $m  * 1000;};										// mm = m * 1000
		$mu_base  		= function($mc=0 ){ return $mc / 1000000;};									// m  = mc / 1000000    
		$base_mu  		= function($m=0  ){ return $m  * 1000000;};									// mc = m * 1000000
		$nm_base			= function($nm=0 ){ return $nm / 1000000000;};							// m  = nm * 1000000000
		$base_nm			= function($m=0  ){ return $m  * 1000000000;};							// nm = m / 1000000000
		$a_base				= function($a=0  ){ return $a  / 10000000000;};							// m  = a / 10000000000
		$base_a				= function($m=0  ){ return $m  * 10000000000;};							// a  = m * 10000000000
		//length : imperial
		$mi_base			= function($mi=0 ){ return $mi * 1609.344;};								// m  = mi * 1609,344
		$base_mi			= function($m=0  ){ return $m  / 1609.344;};								// mi = m / 1609,344
		$nmi_base 		= function($nm=0 ){ return $nm * 1852.00;};									// m  = nmi * 1852.00
		$base_nmi 		= function($m=0  ){ return $m  / 1852.00;};									// nmi= m / 1852.00							
		$ch_base			= function($ch=0 ){ return $ch * 20.1168;};									// m  = ch * 20.1168						
		$base_ch			= function($m=0  ){ return $m  / 20.1168;};								  // ch = m / 20.1168
		$yd_base			= function($yd=0 ){ return $yd * .9144;};								  	// m  = yd * .9144
		$base_yd			= function($m=0  ){ return $m  / .9144;};								  	// yd = m / .9144
		$ft_base			= function($ft=0 ){ return $ft * .3048;};								  	// m  = ft * .3048
		$base_ft			= function($m=0  ){ return $m  / .3048;};								  	// ft = m / .3048
		$in_base			= function($in=0 ){ return $in * .0254;};								  	// m  = in * .0254
		$base_in			= function($m=0  ){ return $m  / .0254;};								  	// in = m / .0254
		$th_base			= function($th=0 ){ return $th * .0254 / 1000;};						// m  = th * (.0254/1000)
		$base_th			= function($m=0  ){ return $m  / .0254 / 1000;};						// th = m / (.0254/1000)
		//weight -> base = 1 kg
		//weight : metric
		$kg_base			= function($kg=0 ){ return $kg; };													// Kg = Kg
		$base_kg			= function($k=0  ){ return $k; };														// Kg = Kg
		$hg_base			= function($hg=0 ){ return $hg / 10; };											// hg = Kg / 10
		$base_hg			= function($k=0  ){ return $k  * 10; };											// Kg = hg * 10
		$dag_base			= function($da=0 ){ return $da / 100; };										// dag= Kg / 100
		$base_dag			= function($k=0  ){ return $k  * 100; };										// Kg = dag * 100
		$g_base				= function($g=0  ){ return $g  / 1000; };										// g = Kg / 1000
		$base_g				= function($k=0  ){ return $k  * 1000; };										// Kg = g * 1000
		$ct_base			= function($ct=0 ){ return $ct / 5000; };										// ct = kg ×5000
		$base_ct			= function($kg=0 ){ return $kg * 5000; };										// kg = ct / 5000
		$dg_base			= function($dg=0 ){ return $dg / 10000; };									// dg = Kg / 10000
		$base_dg			= function($k=0  ){ return $k  * 10000; };									// Kg = dg * 10000
		$cg_base			= function($cg=0 ){ return $cg / 100000; };									// cg = Kg / 100000
		$base_cg			= function($k=0  ){ return $k  * 100000; };									// Kg = cg * 100000
		$mg_base			= function($mg=0 ){ return $mg / 1000000; };								// mg = Kg / 1000000
		$base_mg			= function($k=0  ){ return $k  * 1000000; };								// Kg = mg * 1000000
		$mcg_base			= function($mc=0 ){ return $mc / 1000000000;};							// mcg= Kg / 1000000000
		$base_mcg			= function($k=0  ){ return $k  * 1000000000; };							// Kg = mcg * 1000000000
		//weight : imperial
		$cwt_base			= function($cwt=0){ return $cwt * 0.45359237 * 112; };			// kg = ...
		$base_cwt			= function($k=0  ){ return $k   / 0.45359237 / 112; };			// oz = ...
		$st_base			= function($st=0 ){ return $st  * 0.45359237 * 14; };				// kg = ...
		$base_st			= function($k=0  ){ return $k   / 0.45359237 / 14; };				// oz = ...
		$lb_base			= function($lb=0 ){ return $lb  * 0.45359237; };						// kg = lb * 0.45359237 —Weights and Measures Act, 1963, Section 1(1)
		$base_lb			= function($k=0  ){ return $k   / 0.45359237; };						// lb = lb / 0.45359237
		$oz_base			= function($oz=0 ){ return $oz  * 0.45359237 / 16; };				// kg = oz * (0.45359237/16)/16
		$base_oz			= function($k=0  ){ return $k   / 0.45359237 * 16; };				// oz = lb / (0.45359237/16)
		$dr_base			= function($dr=0 ){ return $dr  * 0.45359237 / 16 / 16; };	// kg = ...
		$base_dr			= function($k=0  ){ return $k   / 0.45359237 * 16 * 16; };	// oz = ...
		$gr_base			= function($gr=0 ){ return $gr  * 0.45359237 / 7000; };			// kg = oz * (0.45359237/16)
		$base_gr			= function($k=0  ){ return $k   / 0.45359237 * 7000; };			// oz = lb / (0.45359237/16)
		//time -> base = 1 second
		$ms_base			= function($m=0  ){ return $m * 0.001; };														
		$base_ms			= function($s=0  ){ return $s / 0.001; };	
		$s_base				= function($s=0  ){ return $s; };														
		$base_s				= function($s=0  ){ return $s; };	
		$mn_base			= function($m=0  ){ return $m * 60; };														
		$base_mn			= function($s=0  ){ return $s / 60; };	
		$hr_base			= function($h=0  ){ return $h * 3600; };														
		$base_hr			= function($s=0  ){ return $s / 3600; };	
		$d_base				= function($d=0  ){ return $d * 86400; };														
		$base_d				= function($s=0  ){ return $s / 86400; };	
		$w_base				= function($d=0  ){ return $d * 604800; };														
		$base_w				= function($s=0  ){ return $s / 604800; };
		$mt_base			= function($d=0  ){ return $d * 2628000; };														
		$base_mt			= function($s=0  ){ return $s / 2628000; };
		$yr_base			= function($d=0  ){ return $d * 31536000; };														
		$base_yr			= function($s=0  ){ return $s / 31536000; };	
		//digital storage -> base = 1byte
		$bit_base				= function($x=0  ){ return $x / 8; };
		$base_bit				= function($x=0  ){ return $x * 8; };
		$B_base					= function($x=0  ){ return $x; }; 
		$base_B					= function($x=0  ){ return $x; };
		$kB_base				= function($x=0  ){ return $x * pow(10,3); }; 
		$base_kB				= function($x=0  ){ return $x / pow(10,3); };
		$MB_base				= function($x=0  ){ return $x * pow(10,6); };
		$base_MB				= function($x=0  ){ return $x / pow(10,6); };
		$GB_base				= function($x=0  ){ return $x * pow(10,9); };
		$base_GB				= function($x=0  ){ return $x / pow(10,9); };
		$TB_base				= function($x=0  ){ return $x * pow(10,12); };
		$base_TB				= function($x=0  ){ return $x / pow(10,12); };
		$PB_base				= function($x=0  ){ return $x * pow(10,15); };
		$base_PB				= function($x=0  ){ return $x / pow(10,15); };
		$EB_base				= function($x=0  ){ return $x * pow(10,18); };
		$base_EB				= function($x=0  ){ return $x / pow(10,18); };
		$ZB_base				= function($x=0  ){ return $x * pow(10,21); };
		$base_ZB				= function($x=0  ){ return $x / pow(10,21); };
		$YB_base				= function($x=0  ){ return $x * pow(10,24); };
		$base_YB				= function($x=0  ){ return $x / pow(10,24); };
		$kiB_base				= function($x=0  ){ return $x * pow(2,10); };
		$base_kiB				= function($x=0  ){ return $x / pow(2,10); };
		$MiB_base				= function($x=0  ){ return $x * pow(2,20); };
		$base_MiB				= function($x=0  ){ return $x / pow(2,20); };
		$GiB_base				= function($x=0  ){ return $x * pow(2,30); };
		$base_GiB				= function($x=0  ){ return $x / pow(2,30); };
		$TiB_base				= function($x=0  ){ return $x * pow(2,40); };
		$base_TiB				= function($x=0  ){ return $x / pow(2,40); };
		$PiB_base				= function($x=0  ){ return $x * pow(2,50); };
		$base_PiB				= function($x=0  ){ return $x / pow(2,50); };
		$EiB_base				= function($x=0  ){ return $x * pow(2,60); };
		$base_EiB				= function($x=0  ){ return $x / pow(2,60); };
		$ZiB_base				= function($x=0  ){ return $x * pow(2,70); };
		$base_kiZ				= function($x=0  ){ return $x / pow(2,70); };
		$YiB_base				= function($x=0  ){ return $x * pow(2,80); };
		$base_kiY				= function($x=0  ){ return $x / pow(2,80); };
		//speed -> base = kmph
		$kmh_base				= function($x=0  ){ return $x; };
		$base_kmh				= function($x=0  ){ return $x; };
		$mph_base				= function($x=0  ){ return $x * 1.609344; };
		$base_mph				= function($x=0  ){ return $x / 1.609344; };
		$fts_base				= function($x=0  ){ return $x * 1.09728; };
		$base_fts				= function($x=0  ){ return $x / 1.09728; };
		$mps_base				= function($x=0  ){ return $x * 3.6; };
		$base_mps				= function($x=0  ){ return $x / 3.6; };
		$kn_base				= function($x=0  ){ return $x * 1.852; };
		$base_kn				= function($x=0  ){ return $x / 1.852; };
		
		
		$to_base = $from.'_base';
		$to_output = 'base_'.$to;
		
		if ((!isset($$to_base))||(!isset($$to_output))){ return '{formula not found}'; } //check if the formula is available
		
		$base = $$to_base($val);
		$output_val = $$to_output($base); 

		//decimal handling ?
		
		return $output_val;
	}
	
	/**
	 * @param (string) 'in' or 'out'
	 * @return val
	 */
	private function currency_conversion($from = 'EUR',$to = 'USD',$val= 1)
	{
		if(!$this->currency_lib):
			return '?';
		else:
			$from_caps = trim(strtoupper($from));
			$to_caps = trim(strtoupper($to));
			$rates= get_object_vars($this->currency_lib->rates);
			
			$output = ($val / $rates[$from_caps]) * $rates[$to_caps];
			
			return $output;
		endif;
	}
	
	/**
	 * @param all the above...
	 * @return none
	 */
	private function add_to_lib($visible_in_lists,$prio,$identifier,$cat,$regex,$name,$displayname,$outputs)
	{
		$temp = array(
			'c'=>$cat,
			'r'=>$regex,
			'n'=>$name,
			'dn'=>$displayname,
			'o'=>$outputs,
			'p'=>$visible_in_lists,
			'prio'=>$prio
			);
		$this->lib[$identifier] = $temp;
	}
	
	/** #9
	 * - the unit and the short name are valid answers to activate
	 * - the regex is fot find matches on search
	 * - category
	 * - display name
	 * - output units
	 * - popular ( show in default results or not )
	 * @param none
	 * @return none
	 */
	private function populate_lib()
	{
		$this->add_to_lib(1,0,'k'			,'temperature'	,'|K|kelvin|'											,'kelvin'				  ,'Kelvin'					,'f|c|r|ro|ra|de'							); 
		$this->add_to_lib(1,0,'f'			,'temperature'	,'|F|°f|fahrenheit|'							,'fahrenheit'			,'°Fahrenheit'		,'c|k|r|ro|ra|de'							); 
		$this->add_to_lib(1,1,'c'			,'temperature'	,'|C|°c|celsius|'									,'celsius'				,'°Celsius'				,'f|k|r|ro|ra|de'							); 
		$this->add_to_lib(1,0,'r'			,'temperature'	,'|r|Re|°r|°Re|reaumur|'					,'reaumur'				,'Réaumur'				,'f|c|k|ro|ra|de'							); 
		$this->add_to_lib(1,0,'ro'		,'temperature'	,'|Ro|°ro|°rø|romer|'							,'romer'					,'Rømer'					,'f|c|k|r|ro|de'							); 
		$this->add_to_lib(1,0,'ra'		,'temperature'	,'|Ra|°Ra|rankine|'								,'rankine'				,'Rankine'				,'f|c|k|r|ro|de'							); 
		$this->add_to_lib(1,0,'de'		,'temperature'	,'|D|De|delisle|'									,'delisle'				,'Delisle'				,'f|c|k|r|ro|ra'							);									
		$this->add_to_lib(1,0,'Gm'		,'length'				,'|Gm|gigameter|'									,'gigameter'			,'Gigameter'			,'hm|dam|m'										); 
		$this->add_to_lib(1,0,'Mm'		,'length'				,'|Mm|megameter|'									,'megameter'			,'Megameter'			,'hm|dam|m'										); 
		$this->add_to_lib(1,0,'km'		,'length'				,'|km|kilometer|'									,'kilometer'		  ,'Kilometer'			,'mi|yd|in'	 									); 
		$this->add_to_lib(1,0,'hm'		,'length'				,'|hm|hectometer|'								,'hectometer'		  ,'Hectometer'			,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); 
		$this->add_to_lib(1,0,'dam'		,'length'				,'|dam|decameter|'								,'decameter'		  ,'Decameter'			,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); 
		$this->add_to_lib(1,0,'m'			,'length'				,'|m|meter|'											,'meter'				  ,'Meter'					,'km|hm|m|dm|cm|mm|mu|nm|a'	 	); 
		$this->add_to_lib(1,0,'dm'		,'length'				,'|dm|decimeter|'									,'decimeter'		  ,'Decimeter'			,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); 
		$this->add_to_lib(1,0,'cm'		,'length'				,'|cm|centimeter|'								,'centimeter'		  ,'Centimeter'			,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); 
		$this->add_to_lib(1,0,'mm'		,'length'				,'|mm|millimeter|'								,'millimeter'		  ,'Millimeter'			,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); 
		$this->add_to_lib(1,0,'mu'		,'length'				,'|µm|mu|micrometer|'							,'micrometer'			,'Micrometer'			,'hm|dam|m|dm|cm|mm|mu|nm|a'	);
		$this->add_to_lib(1,0,'nm'		,'length'				,'|nm|nanometer|'									,'nanometer'			,'Nanometer'			,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); 
		$this->add_to_lib(1,0,'a'			,'length'				,'|a|ang|strom|Ångström|'					,'angstrom'				,'Ångström'				,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); 
		$this->add_to_lib(1,0,'pm'		,'length'				,'|pm|picometer|'									,'picometer'			,'Picometer'			,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); #!no formula
		$this->add_to_lib(1,0,'fm'		,'length'				,'|fm|femtometer|'								,'femtometer'			,'Femtometer'			,'hm|dam|m|dm|cm|mm|mu|nm|a' 	); #!no formula
	//$this->add_to_lib(1,0,'lea'		,'length'				,'|lea|league|'										,'league'				  ,'League'					,'km|mi'										 	); 
		$this->add_to_lib(1,0,'nmi'		,'length'				,'|nmi|nautical mile|'						,'nautical mile'  ,'Nautical mile'	,'km|mi'											); 
		$this->add_to_lib(1,0,'mi'		,'length'				,'|mi|mile|miles'									,'mile'					  ,'Mile'						,'km|mi'											); 
		$this->add_to_lib(1,0,'ch'		,'length'				,'|ch|chain|chains|'							,'chain'					,'Chain'					,'km|mi'											); #ch !made up!
		$this->add_to_lib(1,0,'yd'		,'length'				,'|yd|yard|yards|'								,'yard'					  ,'Yard'						,'km|mi'											); 
		$this->add_to_lib(1,0,'ft'		,'length'				,'|ft|foot|feet|\'|'							,'foot'					  ,'Foot'						,'cm|in|mm'										); 
		$this->add_to_lib(1,0,'in'		,'length'				,'|in|inch|inches|\"|'						,'inch'					  ,'Inch'						,'cm|yd|dm'										 	);
		$this->add_to_lib(1,0,'th'		,'length'				,'|th|thou|'											,'thou'						,'Thou'						,'in|mm'											);						 
		$this->add_to_lib(1,0,'kg'		,'weight'				,'|kg|kilogram|'									,'kilogram'				,'Kilogram'				,'g|lb'												); 
		$this->add_to_lib(1,0,'hg'		,'weight'				,'|hg|hectogram|'									,'hectogram'			,'Hectogram'			,'kg'												 	);
		$this->add_to_lib(1,0,'dag'		,'weight'				,'|dag|dekagram|'									,'dekagram'				,'Dekagram'				,'kg'												 	);
		$this->add_to_lib(1,0,'g'			,'weight'				,'|g|gram|'												,'gram'						,'gram'						,'kg'												 	);
		$this->add_to_lib(1,0,'dg'		,'weight'				,'|dg|decigram|'									,'decigram'				,'decigram'				,'kg'												 	);
		$this->add_to_lib(1,0,'cg'		,'weight'				,'|cg|centigram|'									,'centigram'			,'centigram'			,'kg'												 	);
		$this->add_to_lib(1,0,'mg'		,'weight'				,'|mg|milligram|'									,'milligram'			,'milligram'			,'kg'												 	);
		$this->add_to_lib(1,0,'mcg'		,'weight'				,'|mcg|µ|microgram|'							,'microgram'			,'microgram'			,'kg'												 	);
		$this->add_to_lib(1,0,'lb'		,'weight'				,'|lb|pound|'											,'pound'					,'Pound'					,'kg'													); 
		$this->add_to_lib(1,0,'oz'		,'weight'				,'|oz|ounce|'											,'ounce'					,'Ounce'					,'g'													); 
		$this->add_to_lib(1,0,'gr'		,'weight'				,'|gr|grains|'										,'grains'					,'Grains'					,'mg'													); 
		$this->add_to_lib(1,0,'dr'		,'weight'				,'|dr|dram|drachm|ʒ|'							,'dram'						,'Dram'						,'mg'													); 
		$this->add_to_lib(1,0,'cwt'		,'weight'				,'|cwt|hundredweight|'						,'hundredweight'	,'Hundredweight'	,'mg'													); 
		$this->add_to_lib(1,0,'st'		,'weight'				,'|st|stone|'											,'stone'					,'Stone'					,'mg'													); 
		$this->add_to_lib(1,0,'ct'		,'weight'				,'|ct|carat|'											,'carat'					,'Carat'					,'mg'													); 
		
		$this->add_to_lib(1,0,'ms'		,'time'					,'|ms|millisecond|'								,'millisecond'		,'Millisecond'		,'s|mn'											); 
		$this->add_to_lib(1,0,'s'			,'time'					,'|s|second|/'										,'second'					,'Second'					,'ms'													); 
		$this->add_to_lib(1,0,'mn'		,'time'					,'|mn|minute|'										,'minute'					,'Minute'					,'s|ms'												); 
		$this->add_to_lib(1,0,'hr'		,'time'					,'|hr|hour|'											,'hour'						,'Hour'						,'s|mn|ms|'										); 
		$this->add_to_lib(1,1,'d'			,'time'					,'|d|day|'												,'day'						,'Day'						,'s|mn|hr'										); 
		$this->add_to_lib(1,0,'w'			,'time'					,'|w|week|'												,'week'						,'Week'						,'s|hr|d'											); 
		$this->add_to_lib(1,0,'mt'		,'time'					,'|mt|month|'											,'month'					,'Month'					,'d|hr'												); 
		$this->add_to_lib(1,0,'yr'		,'time'					,'|yr|year|'											,'year'						,'Year'						,'d|mt'												);
		
		$this->add_to_lib(1,0,'bit'		,'digital','|bit|bits|'								,'bit'						,'Bit'						,'B|kB|MB|GB|TB'	);
		$this->add_to_lib(1,0,'B'			,'digital','|B|bytes|'								,'byte'						,'Byte'						,'B|kB|MB|GB|TB'	);
		$this->add_to_lib(1,0,'kB'		,'digital','|kB|kilobytes|'						,'kilobyte'				,'Kilobyte'				,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'MB'		,'digital','|MB|megabytes|'						,'megabyte'				,'Megabyte'				,'B|kB|MB|GB|TB'  );
		$this->add_to_lib(1,0,'GB'		,'digital','|GB|gigabytes|'						,'gigabyte'				,'Gigabyte'				,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'TB'		,'digital','|TB|terabytes|'						,'terabytes'			,'Terabytes'			,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'PB'		,'digital','|PB|petabytes|'						,'petabytes'			,'Petabytes'			,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'EB'		,'digital','|EB|exabytes|'						,'exabytes'				,'Exabytes'				,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'ZB'		,'digital','|ZB|zettabytes|'					,'zettabytes'			,'Zettabytes'			,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'YB'		,'digital','|YB|yottabytes|'					,'Yottabytes'			,'Yottabytes'			,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'kiB'		,'digital','|kiB|kibibytes|'					,'kibibyte'				,'Kibibyte'				,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'MiB'		,'digital','|MiB|mebibytes|'					,'mebibyte'				,'Mebibyte'				,'B|kB|MB|GB|TB'  );
		$this->add_to_lib(1,0,'GiB'		,'digital','|GiB|gibibytes|'					,'gibibyte'				,'Gibibyte'				,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'TiB'		,'digital','|TiB|tebibytes|'					,'tebibytes'			,'Tebibytes'			,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'PiB'		,'digital','|PiB|pebibytes|'					,'pebibytes'			,'Pebibytes'			,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'EiB'		,'digital','|EiB|exbibytes|'					,'exbibytes'			,'Exbiytes'				,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'ZiB'		,'digital','|ZiB|zebibytes|'					,'zebibytes'			,'Zebibytes'			,'B|kB|MB|GB|TB'  ); 
		$this->add_to_lib(1,0,'YiB'		,'digital','|YiB|yobibytes|'					,'Yobibytes'			,'Yobibytes'			,'B|kB|MB|GB|TB'  ); 
		
		$this->add_to_lib(1,0,'kmh'		,'speed'	,'|km/h|kmph|kilometer|'			,'kilometer per hour'			,'kilometer per hour'		,'mph|mps|kn|fts'  ); 
		$this->add_to_lib(1,0,'mph'		,'speed'	,'|mph|miles|per|'						,'miles per hour'					,'Miles per hour'				,'kn|kmh|mps|fts'  ); 
		$this->add_to_lib(1,0,'fts'		,'speed'	,'|fps|foot per|feet per|'		,'feet per second'				,'Feet per second'			,'mh|mph|mps|kn'  );
		$this->add_to_lib(1,0,'mps'		,'speed'	,'|mps|meter per|'						,'meter per second'				,'Meter per second'			,'fts|kmh|mph|kn'  ); 
		$this->add_to_lib(1,0,'kn'		,'speed'	,'|knot|NMPH|kn|knots|'				,'knot'										,'Knot'									,'kmh|mph|mps|fts'  ); 
		
		$this->add_to_lib(1,0,'aed'	,'currency'		,'|aed|united|arab|emirates|dirham'		,'dirham'									,'United Arab Emirates dirham' 		,'usd|eur|aud'); 		
		$this->add_to_lib(1,0,'aud'	,'currency'		,'|x|aud|$|dollar|austr|alian|'				,'australian dollar'			,'Australian dollar' 							,'usd|gbp|eur'); 		
		$this->add_to_lib(1,0,'ars'	,'currency'		,'|ars|argentine|peso|$|'							,'argentine peso'					,'Argentine peso' 								,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'awg'	,'currency'		,'|awg|Aruban|florin|Afl.'						,'aruban florin'					,'Aruban florin' 									,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'bam'	,'currency'		,'|bam|KM|Bosnia|mark|'							,'convertible mark','Bosnia and Herzegovina convertible mark' ,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'bbd'	,'currency'		,'|bbd|Bds$|Bajan|Bds$|barbadian'			,'barbadian dollar'				,'Barbadian dollar' 							,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'bdt'	,'currency'		,'|bdt|৳|টাকা|Tk|bang|taka'							,'Bangladeshi taka'				,'Bangladeshi taka' 						 	,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'bgn'	,'currency'		,'|bgn|leva|levove|stotinki|лв|bul'		,'bulgarian lev'					,'Bulgarian lev' 									,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'bhd'	,'currency'		,'|bhd|dinar|BD|fils|bahrai|'					,'dinar'						 			,'Bahraini dinar' 								,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'bmd'	,'currency'		,'|bmd|bermuda|BD$|dollar|'						,'bermudian dollar'				,'Bermudian dollar' 							,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'bob'	,'currency'		,'|bob|Bs|bolivia|'										,'boliviano'							,'Bolivian Boliviano' 						,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'brl'	,'currency'		,'|brl|real|R$|brazil|brasil|'				,'brazilian real'					,'Brazilian real' 								,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'bsd'	,'currency'		,'|bsd|B$|bahamian|dollar|'						,'Bahamian dollar'				,'Bahamian dollar' 								,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'cad'	,'currency'		,'|cad|canada|C$|$|dollar'						,'canadian dollar'				,'Canadian dollar' 								,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'chf'	,'currency'		,'|chf|Fr|SFr|swiss|franc'						,'swiss franc'						,'Swiss franc' 										,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'clp'	,'currency'		,'|clp|$|peso|chilian|'								,'chilean peso'						,'Chilean peso' 									,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'cny'	,'currency'		,'|cny|renminbi|RMB|¥|chinese|china'	,'renminbi'						 		,'Renminbi' 											,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'cop'	,'currency'		,'|cop|columbia|peso|$|'							,'colombian peso'					,'Colombian peso' 								,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'czk'	,'currency'		,'|czk|Kč|CZK|kc|czech|crown|koruna|'	,'czech koruna'						,'Czech koruna' 									,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'dkk'	,'currency'		,'|dkk|danish|krown|crown|kr|kroner|'	,'danish krone'						,'Danish krone' 									,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'egp'	,'currency'		,'|egp|E£|LE|egyptian|pound'					,'egyptian pound'		 			,'Egyptian pound' 								,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'eur'	,'currency'		,'|xx|euro|\€|euros|'									,'euro'										,'Euro' 													,'usd|gbp|aud'); 
		$this->add_to_lib(1,0,'fjd'	,'currency'		,'|fjd|FJ$|dollar|fiji|'							,'fiji dollar'						,'Fiji dollar' 										,'usd|gbp|aud'); 	
		$this->add_to_lib(1,0,'gbp'	,'currency'		,'|gbp|£|pound|british|sterling|'			,'british pound' 					,'British Pound' 									,'usd|eur|aud'); 
		$this->add_to_lib(1,0,'ghs'	,'currency'		,'|ghs|GH₵|cedi|ghana'								,'Ghana cedi'							,'Ghana cedi' 										,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'gmd'	,'currency'		,'|gmd|gambia|bututs|dalasi|D|'				,'Gambian dalasi'					,'Gambian dalasi' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'gtq'	,'currency'		,'|gtq|guatemala|quetzal|Q|'					,'guatemalan quetzal'			,'Guatemalan quetzal' 						,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'hkd'	,'currency'		,'|hkd|$|HK$|hong|dollar|'						,'Hong Kong dollar'				,'Hong Kong dollar' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'hrk'	,'currency'		,'|hrk|lipa|kn|lp|croatia|kuna|'			,'croatian kuna'					,'Croatian kuna' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'huf'	,'currency'		,'|huf|Ft|hungaria|forint|'						,'hungarian forint'				,'Hungarian forint' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'idr'	,'currency'		,'|idr|Rp|indonesia|perak|rupiah|'		,'indonesian rupiah'			,'Indonesian rupiah' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'ils'	,'currency'		,'|ils|shekel|israeli|₪|nis|ils|'			,'israeli new shekel'			,'Israeli new shekel' 						,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'inr'	,'currency'		,'|inr|indian|rupee|rs|'							,'indian rupee'						,'Indian rupee' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'isk'	,'currency'		,'|isk|iceland|krona|kr|ikr|'					,'icelandic krona'				,'Icelandic króna' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'jmd'	,'currency'		,'|jmd|dollar|J$|jamaican|'						,'jamaican dollar'				,'Jamaican dollar' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'jod'	,'currency'		,'|jod|dinar|jordanian|JD|qirsh|'			,'jordanian dinar'				,'Jordanian dinar' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'dpy'	,'currency'		,'|jpy|¥|yen|japanese|'								,'yen'						 				,'Japanese yen' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'kes'	,'currency'		,'|kes|KSh|kenya|schilling'						,'kenyan shilling'				,'Kenyan shilling' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'khr'	,'currency'		,'|khr|KHR|cambodian|riel'						,'cambodian riel'					,'Cambodian riel' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'krw'	,'currency'		,'|krw|₩|jeon|korean|won|'						,'south korean won'				,'South Korean won' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'kwd'	,'currency'		,'|kwd|k.d.|kuwaiti|dinar|'						,'kuwaiti dinar'					,'Kuwaiti dinar' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'lak'	,'currency'		,'|lak|₭|₭N|lao|kip|'									,'Lao kip'								,'Lao kip' 												,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'lbp'	,'currency'		,'|lbp|L£|lebanon|pound|'							,'Lebanese pound'					,'Lebanese pound' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'lkr'	,'currency'		,'|lkr|Rs|SLRs|sri|rupee|'						,'sri Lankan rupee'				,'Sri Lankan rupee' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'ltl'	,'currency'		,'|ltl|Lt|lithuan|litas|'							,'Lithuanian litas'				,'Lithuanian litas' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'lvl'	,'currency'		,'|lvl|ls|lats|latvia|'								,'Latvian lats'						,'Latvian lats' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'mad'	,'currency'		,'|mad|moroccan|dirham|'							,'Moroccan dirham'				,'Moroccan dirham' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'mdl'	,'currency'		,'|mdl|lei|leu|moldavan|'							,'Moldovan leu'						,'Moldovan leu' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'mga'	,'currency'		,'|mga|ar|malagasy|ariary|'						,'Malagasy ariary'				,'Malagasy ariary' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'mkd'	,'currency'		,'|mkd|denar|denari|macedon|'					,'Macedonian denar'				,'Macedonian denar' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'mur'	,'currency'		,'|mur|rupee|rs|mauritian|'						,'Mauritian rupee'				,'Mauritian rupee' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'mvr'	,'currency'		,'|mvr|rf|mrf|maldivian|rufiyaa|'			,'Maldivian rufiyaa'			,'Maldivian rufiyaa' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'msn'	,'currency'		,'|mxn|mex$|peso|mexican'							,'Mexican peso'						,'Mexican peso' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'myr'	,'currency'		,'|myr|rm$|ringgit|malaysia|'					,'Malaysian ringgit'			,'Malaysian ringgit' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'nad'	,'currency'		,'|nad|n$|namibian|dollar'						,'Namibian dollar'				,'Namibian dollar' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'ngn'	,'currency'		,'|ngn|naira|kobo|₦|nigerian|'				,'Nigerian naira'					,'Nigerian naira' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'nok'	,'currency'		,'|nok|kr|kroner|norwegian|'					,'Norwegian krone'				,'Norwegian krone' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'npr'	,'currency'		,'|npr|nepal|rupee|rs|'								,'Nepalese rupee'					,'Nepalese rupee' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'znd'	,'currency'		,'|nzd|wiki|nz$|new zealand|dollar'		,'New Zealand dollar'			,'New Zealand dollar' 						,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'omr'	,'currency'		,'|omr|omani|rial|'										,'Omani rial'							,'Omani rial' 										,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'pab'	,'currency'		,'|pab|B/|dollar|panama|balboa'				,'Panamanian balboa'			,'Panamanian balboa' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'Pen'	,'currency'		,'|pen|s/|peruvian|sole|'							,'Peruvian nuevo sol'			,'Peruvian nuevo sol' 						,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'php'	,'currency'		,'|php|piso|peso|philippine|'					,'Philippine peso'				,'Philippine peso' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'pkr'	,'currency'		,'|pkr|rs|pakistani|rupee|'						,'Pakistani rupee'				,'Pakistani rupee' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'pln'	,'currency'		,'|pln|polish|zloty|zł'								,'Polish zloty'						,'Polish złoty' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'pyg'	,'currency'		,'|pyg|₲|paraguayan|guarani|'					,'Paraguayan guaraní'			,'Paraguayan guaraní' 						,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'qar'	,'currency'		,'|qar|qatari|riyal|QR|dirham|'				,'Qatari riyal'						,'Qatari riyal' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'ron'	,'currency'		,'|ron|rol|romanian|leu'							,'Romanian leu'						,'Romanian leu' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'rsd'	,'currency'		,'|rsd|serbian|dinar|para|'						,'Serbian dinar'					,'Serbian dinar' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'rub'	,'currency'		,'|rub|/p|russian|ruble|'							,'Russian ruble'					,'Russian ruble' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'sar'	,'currency'		,'|sar|sr|Saudi|riyal|'								,'Saudi riyal'						,'Saudi riyal' 										,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'scr'	,'currency'		,'|scr|Seychellois|rupee|sre|'				,'Seychellois rupee'			,'Seychellois rupee' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'sek'	,'currency'		,'|sek|kr|Swedish|krona|'							,'Swedish krona'					,'Swedish krona' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'sgd'	,'currency'		,'|sgd|s$|singapore|dollar|'					,'Singapore dollar'				,'Singapore dollar' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'syp'	,'currency'		,'|syp|£S|ls|syrian|pound|'						,'Syrian pound'						,'Syrian pound' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'thb'	,'currency'		,'|thb|฿|thai|baht|'									,'Thai baht'						 	,'Thai baht' 											,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'tnd'	,'currency'		,'|tnd|Tunisian|dinar|'								,'Tunisian dinar'					,'Tunisian dinar' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'try'	,'currency'		,'|try|Turkish| TL|lira'							,'Turkish lira'						,'Turkish lira' 									,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'twd'	,'currency'		,'|twd|new taiwan|NT$|dollar|'				,'New Taiwan dollar'			,'New Taiwan dollar' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'uah'	,'currency'		,'|uah|₴|Ukrainian|hryvnia|'					,'Ukrainian hryvnia'			,'Ukrainian hryvnia' 							,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'ugx'	,'currency'		,'|ugx|Ugandan|shilling|ush|'					,'Ugandan shilling'				,'Ugandan shilling' 							,'usd|eur|gbp'); 		
		$this->add_to_lib(1,0,'usd'	,'currency'		,'|xy|usd|$|dollar|U.S.Dollar|united|','dollar'									,'U.S. Dollar' 										,'eur|gbp|aud'); 
		$this->add_to_lib(1,0,'uyu'	,'currency'		,'|uyu|$U|uruguayan|peso|'						,'Uruguayan peso'					,'Uruguayan peso' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'vef'	,'currency'		,'|vef|Venezuelan|bolivar|'						,'Venezuelan bolivar'			,'Venezuelan bolívar' 						,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'vnd'	,'currency'		,'|vnd|Vietnamese|dong|₫'							,'Vietnamese dong'				,'Vietnamese dong' 								,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'xaf'	,'currency'		,'|xaf|CFA|franc'											,'CFA franc'						 	,'CFA franc' 											,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'xcd'	,'currency'		,'|xcd|East|Caribbean|dollar|'				,'East Caribbean dollar'	,'East Caribbean dollar' 					,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'xof'	,'currency'		,'|xof|West African|CFA|franc|'				,'West African CFA franc'	,'West African CFA franc' 				,'usd|eur|gbp'); 	
		$this->add_to_lib(1,0,'xpf'	,'currency'		,'|xpf|CFP|franc|'										,'CFP franc'							,'CFP franc' 											,'usd|eur|gbp'); 
		$this->add_to_lib(1,0,'zar'	,'currency'		,'|zar|South|African|rand|'						,'South African rand'			,'South African rand' 						,'usd|eur|gbp'); 
		
		/*
		$this->add_to_lib(1,0,'cc'		,'cooking'			,'|cc|milliliter|'								,'cc'						,'Mililiter'				,'cc'												);
		$this->add_to_lib(1,0,'cup'		,'cooking'			,'|cup|'													,'cup'						,'Cup'					,'cc'												);
		$this->add_to_lib(1,0,'cupuk'		,'cooking'		,'|cup|'													,'cupuk'					,'Mililiter'				,'cc'												);
		$this->add_to_lib(1,0,'tbs'		,'cooking'			,'|cc|milliliter|'								,'tabelspoon'						,'Tablespoon'				,'cc'												);
		$this->add_to_lib(1,0,'tea'		,'cooking'			,'|cc|milliliter|'								,'teaspoon'						,'Tablespoon'				,'cc'												);
		$this->add_to_lib(1,0,'tea'		,'cooking'			,'|cc|milliliter|'								,'teaspoon'						,'Tablespoon'				,'cc'												); 
*/
		
														
	}
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	<?xml version="1.0"?>

<items>

<!--
  Example of using icon type 'fileicon' to load the file icon directly.
  This item is of type "file" which means it will be treated as a file in
  Alfred's results, so can be actioned and revealed in finder.
  Autocomplete sets what will complete when the user autocompletes.
-->

  <item uid="desktop" arg="~/Desktop" valid="YES" autocomplete="Desktop" type="file">
    <title>Desktop</title>
    <subtitle>~/Desktop</subtitle>
    <icon type="fileicon">~/Desktop</icon>
  </item>

<!--
  Example of loading an icon from the Workflow's folder.
  This item is set as valid no, which means it won't be actioned
-->

  <item uid="flickr" valid="no" autocomplete="flickr">
    <title>Flickr</title>
    <icon>flickr.png</icon>
  </item>

<!--
  Example of using icon type 'filetype' to load the icon for the file type.
  This item is of type "file" which means it will be treated as a file in
  Alfred's results, so can be actioned and revealed in finder.
-->

  <item uid="image" autocomplete="My holiday photo" type="file"> 
    <title>My holiday photo</title> 
    <subtitle>~/Pictures/My holiday photo.jpg</subtitle> 
    <icon type="filetype">public.jpeg</icon> 
  </item> 

</items>




alfred://say+test

 */
	
	
		/**
	 * @param none
	 * @return bundle id
	 */
	private function bundleid()
	{
		$bundleid = $this->alfred->bundle();
		$this->alfred->result( 0,$bundleid,$bundleid,'subtitle','icons/debug.png','yes',null);
	}
	
	private function phpversion()
	{
		$phpversion = phpversion();
		$this->alfred->result( 0,$phpversion,$phpversion,'subtitle','icons/debug.png','yes',null);
	}
	
	
	
	
	/**
	 * refresh currency thing
	 * @param (string) 'in' or 'out'
	 * @return val
	 */
	private function refresh()
	{
		$xml = $this->alfred->request( $this->currency_source );
		$xml = simplexml_load_string( utf8_encode($xml) );
		
		if($xml->channel->lastBuildDate):
		
			$int = 1;
			$new_data = array(); //new stdClass(); //new stdobject() 
			$new_data['updated'] = strtotime($xml->channel->lastBuildDate);
			$new_data['gen_time'] = time();
			$new_data['rates'] = array();
			
			foreach( $xml->channel->item as $item ):
				
				$currency = substr($item->title, 0,3); //781,158,000
				
				$value = str_replace('1 United States Dollar = ','',$item->description);
				$value = explode(' ', $value);
				$value = floatval(str_replace(',','',$value[0]));
				$new_data['rates'][$currency] = $value;
				$int++;
				
			endforeach;			
	
			$this->alfred->write( $new_data ,$this->currency_cache); 
			
			$this->alfred->result( 0,0,'currency values updated','..','icons/debug.png','yes',null);
		else:
		
			$this->alfred->result( 0,0,'old currency values','..','icons/debug.png','yes',null);
		endif;
		
		//echo 'currencies updated';
		//$this->alfred->result( 0,0,'currencies updated','successfull or not','icons/debug.png','yes',null);
	}
	
		/**
	 * @param (string) 'in' or 'out'
	 * @return val
	 */
	private function populate_currency()
	{
		//return false;
		$cache = $this->alfred->read($this->currency_cache);
		
		if(is_null($cache)):
			$fallback_cache = $this->alfred->read('data/currencies_fallback.json');
			if(is_null($fallback_cache)):
				$this->alfred->result(0,0,'{cant read currency cache'.'}','[debug]','icons/debug.png','no'); 
				return false;
			else:
				$this->currency_lib = $fallback_cache;
			endif;
		else:
			$this->currency_lib = $cache;
		endif;
		
		$this->currency_date = date('M jS g:i A',$this->currency_lib->updated);
		if($this->currency_lib->gen_time < time() - 60*60*5):
			$this->refresh();
		endif;
		

	}
	
	/* -------------------  CURRENCY SETUP -------------------- */
	
	private function set_currency_lib()
	{
		if(!$currency_cache = $this->alfred->read($this->currency_cache)):
			if(!$currency_cache = $this->alfred->read($this->currency_cache_fallback)):
				$currency_cache = null;
			endif;
		endif;
		
		if(!$currency_cache):
				echo 'fallback doesnt work';
		else: 
				$this->currency_date = date('M jS g:i A',$currency_cache->updated);
				$this->currency_lib = $currency_cache;
				
				if($this->currency_lib->gen_time < time() - 60*60*5):
					$refresh = $this->make_currency_lib();//dont care if it fails
				endif;
		endif;	
	}

	private function make_currency_lib()
	{
		if(!$lasttime = $this->alfred->read('last_try.json')):
			$this->alfred->write(array('lasttime'=>time()),'last_try.json'); // write out
		else:
			if($lasttime->lasttime > time()-(60)):
				return false;
			endif;
		endif;
		//set last time you tried to now...
		//if last time is not that long ago.. abort
		if(!$xml = $this->alfred->request( $this->currency_source )):
			return false;
		endif;
		if( substr($xml,1,4) !== 'rss'): //request result
			$xml = simplexml_load_string( utf8_encode($xml) );
			if($xml->channel->lastBuildDate): //valid result
				$int = 1;
				$new_data = array(); 
				$new_data['updated'] = strtotime($xml->channel->lastBuildDate);
				$new_data['gen_time'] = time();
				$new_data['rates'] = array();
				foreach( $xml->channel->item as $item ):
					$currency = substr($item->title, 0,3); //781,158,000
					$value = str_replace('1 United States Dollar =','',$item->description);
					//$value = explode(' ', $value);
					$value = $this->extract_float($value);
					$new_data['rates'][$currency] = $value;
					$int++;
				endforeach;			
				if($this->alfred->write($new_data,$this->currency_cache)): // write out
						$this->alfred->result(0,0,'"fresh currency values"','units','icons/debug.png','no');
						return $new_data;
				endif;
			endif;
		else:
			$this->alfred->result(0,0,'"something went wrong"',$xml,'icons/debug.png','no');
		endif;
		return false;
	}
	
	/* -------------------  BRAINS FOR MEMORY -------------------- */
	
	private function set_brain()
	{
		if(!$brain_cache = $this->alfred->read($this->brain_cache)):
			$this->make_brain();
		else:
			$this->brain = (array)$brain_cache; 
		endif;
	}
	
	private function brain_val($unit = null)
	{
		if((!$unit)||(!$this->brain[$unit])):
			return false;
		else:
			return 9 / $this->brain['total'] * $this->brain[$unit];
		endif;	
	}
	
	private function brain_point($unit = null)
	{
		if((!$unit)||(!$this->brain)):
			return false;
		else:	
		 
			if($this->brain[$unit]):
				$this->brain[$unit] += 1;
			else:
				$this->brain[$unit] = 1;
			endif;
			if($this->brain['total']):
				$this->brain['total'] += 1;
			else:
				$this->brain['total'] = 1;
			endif;
		endif;	
	}
	
	
	
	private function make_brain()
	{
		$brain = array('total'=>0);
		if( $this->alfred->write($brain,'unit_brain.json')):
			// new brain made
		else:
		endif;
	}
	
	private function save_brain()
	{
		if( $this->alfred->write($this->brain,'unit_brain.json')):
			// saved
		else:
		endif;
	}
	
	
		/**
	 * @param (string) 'in' or 'out'
	 * @return val
	 */
	private function update()
	{
		//doesn't work - whatsover.... awesome idea though
		$c = $this->alfred->request('http://creatiefgedaan.nl/alfred/units/my_units.alfredworkflow');
		
		$this->alfred->write( $c ,$this->currency_cache); 

		$this->alfred->result(0,0,'{done}','[debug]','icons/debug.png','no'); 
	/*
	if (( is_string($c))) { //($c !== 200) || 
                    $this->alfred->result(0,0,'{ (string) update failed}','[debug]','','no'); 
                    //exit;
                }
            else{
     $this->alfred->result(0,0,'{'.'file in alfred}','[debug]','','no'); 
      }
*/
		 //$zip = $this->alfred->path(). 'workflow.zip';
     //file_put_contents($zip, $c);
     /*
$phar = new PharData($zip);
     foreach ($phar as $path => $file) {
         copy($path, __DIR__ . '/' . $file->getFilename());
     }
*/
     //unlink($zip);
     //Workflow::deleteCache();
     //echo 'Successfully updated the GitHub Workflow';
	}
	
	/**
	 * makes it visible which values we where able to capture
	 * ads a pseudo element to the results that looks something like this
	 *
	 * {5.4}{km}{}[][mi](category)
	 *
	 * @param none
	 * @return bundle id
	 */
	private function start_debug()
	{
		if($this->debugging == true){
		ob_start();
		}
	}
	private function show_debug_result()
	{
		if($this->debugging == true){
		
		
		$this->alfred->result(0,0,'{'.$this->in_val.'}'.'{'.$this->in_type.'}'.'{'.$this->out_type.'}'.'['.($this->spaced?'yes':'no').']['.$this->type_raw.']('. $this->category.')','[debug]','icons/debug.png','no'); 
		
		$result = ob_get_clean();
		$this->alfred->write( $result, 'data/dump.txt');
		}
	}
	
	
	/**
	 * makes it visible which values we where able to capture
	 * ads a pseudo element to the results that looks something like this
	 *
	 * {5.4}{km}{}[][mi]
	 *
	 * @param none
	 * @return bundle id
	 */
	private function dump_it($val,$print_r = false)
	{
		ob_start();
		if($print_r):
			print_r($val);
		else:
			var_dump($val);
		endif;
		$result = ob_get_clean();
		$this->alfred->write( $result, 'data/dump.txt');
	}
	
		/**
	 * extrac a float from a messy string
	 *
	 * @param (string)
	 * @return pretty(float) or a 1
	 */
	private function extract_float($str)
	{
		$str = preg_replace('/[^0-9.,\-]/', '', $str); //only allow - , . 0-9
		
		if(empty($str)):
			return 1;
		endif;
		
		if(strlen(preg_replace('/[^.,]/', '', $str)) == 2):
			$dotsandcommas = preg_replace('/[^.,]/', '', $str); //only dots and comma's
			$str = str_replace($dotsandcommas[0],'',$str); //strip comma's
		elseif(substr_count($str, ",") > 1):
			$str = str_replace(',','',$str); //strip comma's
		elseif(substr_count($str, ".") > 1): 
			$core = str_replace('.','',$str);//strip dots
		endif;

		return floatval(str_replace(',','.',$str));
	}
	
	/** 
	 * @param (string)
	 * @param (bool)
	 * @return null or valid type
	 */
	private function extract_type($str,$strip_numbers = false)
	{
		$str = str_replace('-','',$str);//remove dashes
		
		$input_is_spaced = (strpos($this->raw_query,$str.' ') === false ? false : true );
		$is_for_input = (isset($this->in_type)? false : true);
		
		if($strip_numbers === true):
			$str = str_replace(',','',str_replace('.','', str_replace(range(0,9),'',$str)));
		endif;
	
		if(($this->spaced)||(($is_for_input)&&($input_is_spaced))): //dont return without space (confirmation)
			foreach ($this->lib as $unit => $data):
				if( ($is_for_input)||(($this->lib[$this->in_type]['c'] == $data['c'])&&($unit !== $this->in_type ))): //not to itself, but same category
						if(($str == $unit)||(strtolower($str) == strtolower($data['n']))): //equal to unit or full for validation
							return $unit;					
						endif;
				endif;
			endforeach;
	  endif;
		
		$this->type_raw = trim($str);
		return null;
	}

}