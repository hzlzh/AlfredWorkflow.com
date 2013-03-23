<?php

/**
 * CFPropertyList
 * {@link http://developer.apple.com/documentation/Darwin/Reference/ManPages/man5/plist.5.html Property Lists}
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @version $Id$
 * @example example-read-01.php Read an XML PropertyList
 * @example example-read-02.php Read a Binary PropertyList
 * @example example-read-03.php Read a PropertyList without knowing the type
 * @example example-create-01.php Using the CFPropertyList API
 * @example example-create-02.php Using {@link CFTypeDetector}
 * @example example-create-03.php Using {@link CFTypeDetector} with {@link CFDate} and {@link CFData}
 * @example example-modify-01.php Read, modify and save a PropertyList
 */

/**
 * Property List
 * Interface for handling reading, editing and saving Property Lists as defined by Apple.
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @example example-read-01.php Read an XML PropertyList
 * @example example-read-02.php Read a Binary PropertyList
 * @example example-read-03.php Read a PropertyList without knowing the type
 * @example example-create-01.php Using the CFPropertyList API
 * @example example-create-02.php Using {@link CFTypeDetector}
 * @example example-create-03.php Using {@link CFTypeDetector} with {@link CFDate} and {@link CFData}
 * @example example-create-04.php Using and extended {@link CFTypeDetector}
 */
class CFPropertyList extends CFBinaryPropertyList implements Iterator {
  /**
   * Format constant for binary format
   * @var integer
   */
  const FORMAT_BINARY = 1;

  /**
   * Format constant for xml format
   * @var integer
   */
  const FORMAT_XML = 2;

  /**
   * Format constant for automatic format recognizing
   * @var integer
   */
  const FORMAT_AUTO = 0;

  /**
   * Path of PropertyList
   * @var string
   */
  protected $file = null;

  /**
   * Path of PropertyList
   * @var integer
   */
  protected $format = null;

  /**
   * CFType nodes
   * @var array
   */
  protected $value = array();

  /**
   * Position of iterator {@link http://php.net/manual/en/class.iterator.php}
   * @var integer
   */
  protected $iteratorPosition = 0;

  /**
   * List of Keys for numerical iterator access {@link http://php.net/manual/en/class.iterator.php}
   * @var array
   */
  protected $iteratorKeys = null;

  /**
   * List of NodeNames to ClassNames for resolving plist-files
   * @var array
   */
  protected static $types = array(
    'string'  => 'CFString',
    'real'    => 'CFNumber',
    'integer' => 'CFNumber',
    'date'    => 'CFDate',
    'true'    => 'CFBoolean',
    'false'   => 'CFBoolean',
    'data'    => 'CFData',
    'array'   => 'CFArray',
    'dict'    => 'CFDictionary'
 );


  /**
   * Create new CFPropertyList.
   * If a path to a PropertyList is specified, it is loaded automatically.
   * @param string $file Path of PropertyList
   * @param integer $format he format of the property list, see {@link FORMAT_XML}, {@link FORMAT_BINARY} and {@link FORMAT_AUTO}, defaults to {@link FORMAT_AUTO}
   * @throws IOException if file could not be read by {@link load()}
   * @uses $file for storing the current file, if specified
   * @uses load() for loading the plist-file
   */
  public function __construct($file=null,$format=self::FORMAT_AUTO) {
    $this->file = $file;
    $this->format = $format;
    if($this->file) $this->load();
  }

  /**
   * Load an XML PropertyList.
   * @param string $file Path of PropertyList, defaults to {@link $file}
   * @return void
   * @throws IOException if file could not be read
   * @throws DOMException if XML-file could not be read properly
   * @uses load() to actually load the file
   */
  public function loadXML($file=null) {
    $this->load($file,CFPropertyList::FORMAT_XML);
  }

  /**
   * Load an XML PropertyList.
   * @param resource $stream A stream containing the xml document.
   * @return void
   * @throws IOException if stream could not be read
   * @throws DOMException if XML-stream could not be read properly
   */
  public function loadXMLStream($stream) {
    if(($contents = stream_get_contents($stream)) === FALSE) throw IOException::notReadable('<stream>');
    $this->parse($contents,CFPropertyList::FORMAT_XML);
  }

  /**
   * Load an binary PropertyList.
   * @param string $file Path of PropertyList, defaults to {@link $file}
   * @return void
   * @throws IOException if file could not be read
   * @throws PListException if binary plist-file could not be read properly
   * @uses load() to actually load the file
   */
  public function loadBinary($file=null) {
    $this->load($file,CFPropertyList::FORMAT_BINARY);
  }

  /**
   * Load an binary PropertyList.
   * @param stream $stream Stream containing the PropertyList
   * @return void
   * @throws IOException if file could not be read
   * @throws PListException if binary plist-file could not be read properly
   * @uses parse() to actually load the file
   */
  public function loadBinaryStream($stream) {
    if(($contents = stream_get_contents($stream)) === FALSE) throw IOException::notReadable('<stream>');
    $this->parse($contents,CFPropertyList::FORMAT_BINARY);
  }

  /**
   * Load a plist file.
   * Load and import a plist file.
   * @param string $file Path of PropertyList, defaults to {@link $file}
   * @param integer $format The format of the property list, see {@link FORMAT_XML}, {@link FORMAT_BINARY} and {@link FORMAT_AUTO}, defaults to {@link $format}
   * @return void
   * @throws PListException if file format version is not 00
   * @throws IOException if file could not be read
   * @throws DOMException if plist file could not be parsed properly
   * @uses $file if argument $file was not specified
   * @uses $value reset to empty array
   * @uses import() for importing the values
   */
  public function load($file=null,$format=null) {
    $file = $file ? $file : $this->file;
    $format = $format !== null ? $format : $this->format;
    $this->value = array();

    if(!is_readable($file)) throw IOException::notReadable($file);

    switch($format) {
      case CFPropertyList::FORMAT_BINARY:
        $this->readBinary($file);
        break;
      case CFPropertyList::FORMAT_AUTO: // what we now do is ugly, but neccessary to recognize the file format
        $fd = fopen($file,"rb");
        if(($magic_number = fread($fd,8)) === false) throw IOException::notReadable($file);
        fclose($fd);

        $filetype = substr($magic_number,0,6);
        $version  = substr($magic_number,-2);

        if($filetype == "bplist") {
          if($version != "00") throw new PListException("Wrong file format version! Expected 00, got $version!");
          $this->readBinary($file);
          break;
        }
        // else: xml format, break not neccessary
      case CFPropertyList::FORMAT_XML:
        $doc = new DOMDocument();
        if(!$doc->load($file)) throw new DOMException();
        $this->import($doc->documentElement, $this);
        break;
    }
  }

  /**
   * Parse a plist string.
   * Parse and import a plist string.
   * @param string $str String containing the PropertyList, defaults to {@link $content}
   * @param integer $format The format of the property list, see {@link FORMAT_XML}, {@link FORMAT_BINARY} and {@link FORMAT_AUTO}, defaults to {@link $format}
   * @return void
   * @throws PListException if file format version is not 00
   * @throws IOException if file could not be read
   * @throws DOMException if plist file could not be parsed properly
   * @uses $content if argument $str was not specified
   * @uses $value reset to empty array
   * @uses import() for importing the values
   */
  public function parse($str=NULL,$format=NULL) {
    $format = $format !== null ? $format : $this->format;
    $str = $str !== null ? $str : $this->content;
    $this->value = array();

    switch($format) {
      case CFPropertyList::FORMAT_BINARY:
        $this->parseBinary($str);
        break;
      case CFPropertyList::FORMAT_AUTO: // what we now do is ugly, but neccessary to recognize the file format
        if(($magic_number = substr($str,0,8)) === false) throw IOException::notReadable("<string>");

        $filetype = substr($magic_number,0,6);
        $version  = substr($magic_number,-2);

        if($filetype == "bplist") {
          if($version != "00") throw new PListException("Wrong file format version! Expected 00, got $version!");
          $this->parseBinary($str);
          break;
        }
        // else: xml format, break not neccessary
      case CFPropertyList::FORMAT_XML:
        $doc = new DOMDocument();
        if(!$doc->loadXML($str)) throw new DOMException();
        $this->import($doc->documentElement, $this);
        break;
    }
  }

  /**
   * Convert a DOMNode into a CFType.
   * @param DOMNode $node Node to import children of
   * @param CFDictionary|CFArray|CFPropertyList $parent
   * @return void
   */
  protected function import(DOMNode $node, $parent) {
    // abort if there are no children
    if(!$node->childNodes->length) return;

    foreach($node->childNodes as $n) {
      // skip if we can't handle the element
      if(!isset(self::$types[$n->nodeName])) continue;

      $class = 'CFPropertyList\\'.self::$types[$n->nodeName];
      $key = null;

      // find previous <key> if possible
      $ps = $n->previousSibling;
      while($ps && $ps->nodeName == '#text' && $ps->previousSibling) $ps = $ps->previousSibling;

      // read <key> if possible
      if($ps && $ps->nodeName == 'key') $key = $ps->firstChild->nodeValue;

      switch($n->nodeName) {
        case 'date':
          $value = new $class(CFDate::dateValue($n->nodeValue));
          break;
        case 'data':
          $value = new $class($n->nodeValue,true);
          break;
        case 'string':
          $value = new $class($n->nodeValue);
          break;

        case 'real':
        case 'integer':
          $value = new $class($n->nodeName == 'real' ? floatval($n->nodeValue) : intval($n->nodeValue));
          break;

        case 'true':
        case 'false':
          $value = new $class($n->nodeName == 'true');
          break;

        case 'array':
        case 'dict':
          $value = new $class();
          $this->import($n, $value);
          break;
      }

      // Dictionaries need a key
      if($parent instanceof CFDictionary) $parent->add($key, $value);
      // others don't
      else $parent->add($value);
    }
  }

  /**
   * Convert CFPropertyList to XML and save to file.
   * @param string $file Path of PropertyList, defaults to {@link $file}
   * @return void
   * @throws IOException if file could not be read
   * @uses $file if $file was not specified
   */
  public function saveXML($file) {
    $this->save($file,CFPropertyList::FORMAT_XML);
  }

  /**
   * Convert CFPropertyList to binary format (bplist00) and save to file.
   * @param string $file Path of PropertyList, defaults to {@link $file}
   * @return void
   * @throws IOException if file could not be read
   * @uses $file if $file was not specified
   */
  public function saveBinary($file) {
    $this->save($file,CFPropertyList::FORMAT_BINARY);
  }

  /**
   * Convert CFPropertyList to XML or binary and save to file.
   * @param string $file Path of PropertyList, defaults to {@link $file}
   * @param string $format Format of PropertyList, defaults to {@link $format}
   * @return void
   * @throws IOException if file could not be read
   * @throws PListException if evaluated $format is neither {@link FORMAT_XML} nor {@link FORMAL_BINARY}
   * @uses $file if $file was not specified
   * @uses $format if $format was not specified
   */
  public function save($file=null,$format=null) {
    $file = $file ? $file : $this->file;
    $format = $format ? $format : $this->format;

    if( !in_array( $format, array( self::FORMAT_BINARY, self::FORMAT_XML ) ) )
      throw new PListException( "format {$format} is not supported, use CFPropertyList::FORMAT_BINARY or CFPropertyList::FORMAT_XML" );

    if(!file_exists($file)) {
      // dirname("file.xml") == "" and is treated as the current working directory
      if(!is_writable(dirname($file))) throw IOException::notWritable($file);
    }
    else if(!is_writable($file)) throw IOException::notWritable($file);

    $content = $format == self::FORMAT_BINARY ? $this->toBinary() : $this->toXML();

    $fh = fopen($file, 'wb');
    fwrite($fh,$content);
    fclose($fh);
  }

  /**
   * Convert CFPropertyList to XML
   * @param bool $formatted Print plist formatted (i.e. with newlines and whitespace indention) if true; defaults to false
   * @return string The XML content
   */
  public function toXML($formatted=false) {
    $domimpl = new DOMImplementation();
    // <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    $dtd = $domimpl->createDocumentType('plist', '-//Apple Computer//DTD PLIST 1.0//EN', 'http://www.apple.com/DTDs/PropertyList-1.0.dtd');
    $doc = $domimpl->createDocument(null, "plist", $dtd);
    $doc->encoding = "UTF-8";

    // format output
    if($formatted) {
      $doc->formatOutput = true;
      $doc->preserveWhiteSpace = true;
    }

    // get documentElement and set attribs
    $plist = $doc->documentElement;
    $plist->setAttribute('version', '1.0');

    // add PropertyList's children
    $plist->appendChild($this->getValue(true)->toXML($doc));

    return $doc->saveXML();
  }


  /************************************************************************************************
   *    M A N I P U L A T I O N
   ************************************************************************************************/

  /**
   * Add CFType to collection.
   * @param CFType $value CFType to add to collection
   * @return void
   * @uses $value for adding $value
   */
  public function add(CFType $value=null) {
    // anything but CFType is null, null is an empty string - sad but true
    if( !$value )
      $value = new CFString();

    $this->value[] = $value;
  }

  /**
   * Get CFType from collection.
   * @param integer $key Key of CFType to retrieve from collection
   * @return CFType CFType found at $key, null else
   * @uses $value for retrieving CFType of $key
   */
  public function get($key) {
    if(isset($this->value[$key])) return $this->value[$key];
    return null;
  }

  /**
   * Generic getter (magic)
   *
   * @param integer $key Key of CFType to retrieve from collection
   * @return CFType CFType found at $key, null else
   * @author Sean Coates <sean@php.net>
   * @link http://php.net/oop5.overloading
   */
  public function __get($key) {
    return $this->get($key);
  }

  /**
   * Remove CFType from collection.
   * @param integer $key Key of CFType to removes from collection
   * @return CFType removed CFType, null else
   * @uses $value for removing CFType of $key
   */
  public function del($key) {
    if(isset($this->value[$key])) {
      $t = $this->value[$key];
      unset($this->value[$key]);
      return $t;
    }

    return null;
  }

  /**
   * Empty the collection
   * @return array the removed CFTypes
   * @uses $value for removing CFType of $key
   */
  public function purge() {
    $t = $this->value;
    $this->value = array();
    return $t;
  }

  /**
   * Get first (and only) child, or complete collection.
   * @param string $cftype if set to true returned value will be CFArray instead of an array in case of a collection
   * @return CFType|array CFType or list of CFTypes known to the PropertyList
   * @uses $value for retrieving CFTypes
   */
  public function getValue($cftype=false) {
    if(count($this->value) === 1) {
      $t = array_values( $this->value );
      return $t[0];
	}
    if($cftype) {
      $t = new CFArray();
      foreach( $this->value as $value ) {
        if( $value instanceof CFType ) $t->add($value);
      }
      return $t;
    }
    return $this->value;
  }

  /**
   * Create CFType-structure from guessing the data-types.
   * The functionality has been moved to the more flexible {@link CFTypeDetector} facility.
   * @param mixed $value Value to convert to CFType
   * @param array $options Configuration for casting values [autoDictionary, suppressExceptions, objectToArrayMethod, castNumericStrings]
   * @return CFType CFType based on guessed type
   * @uses CFTypeDetector for actual type detection
   * @deprecated
   */
  public static function guess($value, $options=array()) {
    static $t = null;
    if( $t === null )
      $t = new CFTypeDetector( $options );

    return $t->toCFType( $value );
  }


  /************************************************************************************************
   *    S E R I A L I Z I N G
   ************************************************************************************************/

  /**
   * Get PropertyList as array.
   * @return mixed primitive value of first (and only) CFType, or array of primitive values of collection
   * @uses $value for retrieving CFTypes
   */
  public function toArray() {
    $a = array();
    foreach($this->value as $value) $a[] = $value->toArray();
    if(count($a) === 1) return $a[0];

    return $a;
  }


  /************************************************************************************************
   *    I T E R A T O R   I N T E R F A C E
   ************************************************************************************************/

  /**
   * Rewind {@link $iteratorPosition} to first position (being 0)
   * @link http://php.net/manual/en/iterator.rewind.php
   * @return void
   * @uses $iteratorPosition set to 0
   * @uses $iteratorKeys store keys of {@link $value}
   */
  public function rewind() {
    $this->iteratorPosition = 0;
    $this->iteratorKeys = array_keys($this->value);
  }

  /**
   * Get Iterator's current {@link CFType} identified by {@link $iteratorPosition}
   * @link http://php.net/manual/en/iterator.current.php
   * @return CFType current Item
   * @uses $iteratorPosition identify current key
   * @uses $iteratorKeys identify current value
   */
  public function current() {
    return $this->value[$this->iteratorKeys[$this->iteratorPosition]];
  }

  /**
   * Get Iterator's current key identified by {@link $iteratorPosition}
   * @link http://php.net/manual/en/iterator.key.php
   * @return string key of the current Item
   * @uses $iteratorPosition identify current key
   * @uses $iteratorKeys identify current value
   */
  public function key() {
    return $this->iteratorKeys[$this->iteratorPosition];
  }

  /**
   * Increment {@link $iteratorPosition} to address next {@see CFType}
   * @link http://php.net/manual/en/iterator.next.php
   * @return void
   * @uses $iteratorPosition increment by 1
   */
  public function next() {
    $this->iteratorPosition++;
  }

  /**
   * Test if {@link $iteratorPosition} addresses a valid element of {@link $value}
   * @link http://php.net/manual/en/iterator.valid.php
   * @return boolean true if current position is valid, false else
   * @uses $iteratorPosition test if within {@link $iteratorKeys}
   * @uses $iteratorPosition test if within {@link $value}
   */
  public function valid() {
    return isset($this->iteratorKeys[$this->iteratorPosition]) && isset($this->value[$this->iteratorKeys[$this->iteratorPosition]]);
  }

}


/**
 * CFPropertyList
 * {@link http://developer.apple.com/documentation/Darwin/Reference/ManPages/man5/plist.5.html Property Lists}
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @version $Id$
 */

/**
 * Facility for reading and writing binary PropertyLists. Ported from {@link http://www.opensource.apple.com/source/CF/CF-476.15/CFBinaryPList.c CFBinaryPList.c}.
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @example example-read-02.php Read a Binary PropertyList
 * @example example-read-03.php Read a PropertyList without knowing the type
 */
abstract class CFBinaryPropertyList {
  /**
   * Content of the plist (unparsed string)
   * @var string
   */
  protected $content = NULL;

  /**
   * position in the (unparsed) string
   * @var integer
   */
  protected $pos = 0;

  /**
   * Table containing uniqued objects
   * @var array
   */
  protected $uniqueTable = Array();

  /**
   * Number of objects in file
   * @var integer
   */
  protected $countObjects = 0;

  /**
   * The length of all strings in the file (byte length, not character length)
   * @var integer
   */
  protected $stringSize = 0;

  /**
   * The length of all ints in file (byte length)
   * @var integer
   */
  protected $intSize = 0;

  /**
   * The length of misc objects (i.e. not integer and not string) in file
   * @var integer
   */
  protected $miscSize = 0;

  /**
   * Number of object references in file (needed to calculate reference byte length)
   * @var integer
   */
  protected $objectRefs = 0;

  /**
   * Number of objects written during save phase; needed to calculate the size of the object table
   * @var integer
   */
  protected $writtenObjectCount = 0;

  /**
   * Table containing all objects in the file
   */
  protected $objectTable = Array();

  /**
   * The size of object references
   */
  protected $objectRefSize = 0;

  /**
   * The „offsets” (i.e. the different entries) in the file
   */
  protected $offsets = Array();

  /**
   * Read a „null type” (filler byte, true, false, 0 byte)
   * @param $length The byte itself
   * @return the byte value (e.g. CFBoolean(true), CFBoolean(false), 0 or 15)
   * @throws PListException on encountering an unknown null type
   */
  protected function readBinaryNullType($length) {
    switch($length) {
      case 0: return 0; // null type
      case 8: return new CFBoolean(false);
      case 9: return new CFBoolean(true);
      case 15: return 15; // fill type
    }

    throw new PListException("unknown null type: $length");
  }

  /**
   * Create an 64 bit integer using bcmath or gmp
   * @param int $hi The higher word
   * @param int $lo The lower word
   * @return mixed The integer (as int if possible, as string if not possible)
   * @throws PListException if neither gmp nor bc available
   */
  protected static function make64Int($hi,$lo) {
    // on x64, we can just use int
    if(PHP_INT_SIZE > 4) return (((int)$hi)<<32) | ((int)$lo);

    // lower word has to be unsigned since we don't use bitwise or, we use bcadd/gmp_add
    $lo = sprintf("%u", $lo);

    // use GMP or bcmath if possible
    if(function_exists("gmp_mul")) return gmp_strval(gmp_add(gmp_mul($hi, "4294967296"), $lo));

    if(function_exists("bcmul")) return bcadd(bcmul($hi,"4294967296"), $lo);

    if(class_exists('Math_BigInteger')) {
      $bi = new \Math_BigInteger($hi);
      return $bi->multiply(new \Math_BigInteger("4294967296"))->add(new \Math_BigInteger($lo))->toString();
    }

    throw new PListException("either gmp or bc has to be installed, or the Math_BigInteger has to be available!");
  }

  /**
   * Read an integer value
   * @param integer $length The length (in bytes) of the integer value, coded as „set bit $length to 1”
   * @return CFNumber The integer value
   * @throws PListException if integer val is invalid
   * @throws IOException if read error occurs
   * @uses make64Int() to overcome PHP's big integer problems
   */
  protected function readBinaryInt($length) {
    if($length > 3) throw new PListException("Integer greater than 8 bytes: $length");

    $nbytes = 1 << $length;

    $val = null;
    if(strlen($buff = substr($this->content, $this->pos, $nbytes)) != $nbytes) throw IOException::readError("");
    $this->pos += $nbytes;

    switch($length) {
      case 0:
        $val = unpack("C", $buff);
        $val = $val[1];
        break;
      case 1:
        $val = unpack("n", $buff);
        $val = $val[1];
        break;
      case 2:
        $val = unpack("N", $buff);
        $val = $val[1];
        break;
      case 3:
        $words = unpack("Nhighword/Nlowword",$buff);
        //$val = $words['highword'] << 32 | $words['lowword'];
        $val = self::make64Int($words['highword'],$words['lowword']);
        break;
    }

    return new CFNumber($val);
  }

  /**
   * Read a real value
   * @param integer $length The length (in bytes) of the integer value, coded as „set bit $length to 1”
   * @return CFNumber The real value
   * @throws PListException if real val is invalid
   * @throws IOException if read error occurs
   */
  protected function readBinaryReal($length) {
    if($length > 3) throw new PListException("Real greater than 8 bytes: $length");

    $nbytes = 1 << $length;
    $val = null;
    if(strlen($buff = substr($this->content,$this->pos, $nbytes)) != $nbytes) throw IOException::readError("");
    $this->pos += $nbytes;

    switch($length) {
      case 0: // 1 byte float? must be an error
      case 1: // 2 byte float? must be an error
        $x = $length + 1;
        throw new PListException("got {$x} byte float, must be an error!");
      case 2:
        $val = unpack("f", strrev($buff));
        $val = $val[1];
        break;
      case 3:
        $val = unpack("d", strrev($buff));
        $val = $val[1];
        break;
    }

    return new CFNumber($val);
  }

  /**
   * Read a date value
   * @param integer $length The length (in bytes) of the integer value, coded as „set bit $length to 1”
   * @return CFDate The date value
   * @throws PListException if date val is invalid
   * @throws IOException if read error occurs
   */
  protected function readBinaryDate($length) {
    if($length > 3) throw new PListException("Date greater than 8 bytes: $length");

    $nbytes = 1 << $length;
    $val = null;
    if(strlen($buff = substr($this->content, $this->pos, $nbytes)) != $nbytes) throw IOException::readError("");
    $this->pos += $nbytes;

    switch($length) {
      case 0: // 1 byte CFDate is an error
      case 1: // 2 byte CFDate is an error
        $x = $length + 1;
        throw new PListException("{$x} byte CFdate, error");

      case 2:
        $val = unpack("f", strrev($buff));
        $val = $val[1];
        break;
      case 3:
        $val = unpack("d", strrev($buff));
        $val = $val[1];
        break;
    }

    return new CFDate($val,CFDate::TIMESTAMP_APPLE);
  }

  /**
   * Read a data value
   * @param integer $length The length (in bytes) of the integer value, coded as „set bit $length to 1”
   * @return CFData The data value
   * @throws IOException if read error occurs
   */
  protected function readBinaryData($length) {
    if($length == 0) $buff = "";
    else {
      $buff = substr($this->content, $this->pos, $length);
      if(strlen($buff) != $length) throw IOException::readError("");
      $this->pos += $length;
    }

    return new CFData($buff,false);
  }

  /**
   * Read a string value, usually coded as utf8
   * @param integer $length The length (in bytes) of the string value
   * @return CFString The string value, utf8 encoded
   * @throws IOException if read error occurs
   */
  protected function readBinaryString($length) {
    if($length == 0) $buff = "";
    else {
      if(strlen($buff = substr($this->content, $this->pos, $length)) != $length) throw IOException::readError("");
      $this->pos += $length;
    }

    if(!isset($this->uniqueTable[$buff])) $this->uniqueTable[$buff] = true;
    return new CFString($buff);
  }

  /**
   * Convert the given string from one charset to another.
   * Trying to use MBString, Iconv, Recode - in that particular order.
   * @param string $string the string to convert
   * @param string $fromCharset the charset the given string is currently encoded in
   * @param string $toCharset the charset to convert to, defaults to UTF-8
   * @return string the converted string
   * @throws PListException on neither MBString, Iconv, Recode being available
   */
  public static function convertCharset($string, $fromCharset, $toCharset='UTF-8') {
    if(function_exists('mb_convert_encoding')) return mb_convert_encoding($string, $toCharset, $fromCharset);
    if(function_exists('iconv')) return iconv($fromCharset, $toCharset, $string);
    if(function_exists('recode_string')) return recode_string($fromCharset .'..'. $toCharset, $string);

    throw new PListException('neither iconv nor mbstring supported. how are we supposed to work on strings here?');
  }

  /**
   * Count characters considering character set
   * Trying to use MBString, Iconv - in that particular order.
   * @param string $string the string to convert
   * @param string $charset the charset the given string is currently encoded in
   * @return integer The number of characters in that string
   * @throws PListException on neither MBString, Iconv being available
   */
  public static function charsetStrlen($string,$charset="UTF-8") {
    if(function_exists('mb_strlen')) return mb_strlen($string, $charset);
    if(function_exists('iconv_strlen')) return iconv_strlen($string,$charset);

    throw new PListException('neither iconv nor mbstring supported. how are we supposed to work on strings here?');
  }

  /**
   * Read a unicode string value, coded as UTF-16BE
   * @param integer $length The length (in bytes) of the string value
   * @return CFString The string value, utf8 encoded
   * @throws IOException if read error occurs
   */
  protected function readBinaryUnicodeString($length) {
    /* The problem is: we get the length of the string IN CHARACTERS;
       since a char in UTF-16 can be 16 or 32 bit long, we don't really know
       how long the string is in bytes */
    if(strlen($buff = substr($this->content, $this->pos, 2*$length)) != 2*$length) throw IOException::readError("");
    $this->pos += 2 * $length;

    if(!isset($this->uniqueTable[$buff])) $this->uniqueTable[$buff] = true;
    return new CFString(self::convertCharset($buff, "UTF-16BE", "UTF-8"));
  }

  /**
   * Read an array value, including contained objects
   * @param integer $length The number of contained objects
   * @return CFArray The array value, including the objects
   * @throws IOException if read error occurs
   */
  protected function readBinaryArray($length) {
    $ary = new CFArray();

    // first: read object refs
    if($length != 0) {
      if(strlen($buff = substr($this->content, $this->pos, $length * $this->objectRefSize)) != $length * $this->objectRefSize) throw IOException::readError("");
      $this->pos += $length * $this->objectRefSize;

      $objects = unpack($this->objectRefSize == 1 ? "C*" : "n*", $buff);

      // now: read objects
      for($i=0;$i<$length;++$i) {
        $object = $this->readBinaryObjectAt($objects[$i+1]+1,$this->objectRefSize);
        $ary->add($object);
      }
    }

    return $ary;
  }

  /**
   * Read a dictionary value, including contained objects
   * @param integer $length The number of contained objects
   * @return CFDictionary The dictionary value, including the objects
   * @throws IOException if read error occurs
   */
  protected function readBinaryDict($length) {
    $dict = new CFDictionary();

    // first: read keys
    if($length != 0) {
      if(strlen($buff = substr($this->content, $this->pos, $length * $this->objectRefSize)) != $length * $this->objectRefSize) throw IOException::readError("");
      $this->pos += $length * $this->objectRefSize;
      $keys = unpack(($this->objectRefSize == 1 ? "C*" : "n*"), $buff);

      // second: read object refs
      if(strlen($buff = substr($this->content, $this->pos, $length * $this->objectRefSize)) != $length * $this->objectRefSize) throw IOException::readError("");
      $this->pos += $length * $this->objectRefSize;
      $objects = unpack(($this->objectRefSize == 1 ? "C*" : "n*"), $buff);

      // read real keys and objects
      for($i=0;$i<$length;++$i) {
        $key = $this->readBinaryObjectAt($keys[$i+1]+1);
        $object = $this->readBinaryObjectAt($objects[$i+1]+1);
        $dict->add($key->getValue(),$object);
      }
    }

    return $dict;
  }

  /**
   * Read an object type byte, decode it and delegate to the correct reader function
   * @return mixed The value of the delegate reader, so any of the CFType subclasses
   * @throws IOException if read error occurs
   */
  function readBinaryObject() {
    // first: read the marker byte
    if(strlen($buff = substr($this->content,$this->pos,1)) != 1) throw IOException::readError("");
    $this->pos++;

    $object_length = unpack("C*", $buff);
    $object_length = $object_length[1]  & 0xF;
    $buff = unpack("H*", $buff);
    $buff = $buff[1];

    $object_type = substr($buff, 0, 1);
    if($object_type != "0" && $object_length == 15) {
      $object_length = $this->readBinaryObject($this->objectRefSize);
      $object_length = $object_length->getValue();
    }

    $retval = null;
    switch($object_type) {
      case '0': // null, false, true, fillbyte
        $retval = $this->readBinaryNullType($object_length);
        break;
      case '1': // integer
        $retval = $this->readBinaryInt($object_length);
        break;
      case '2': // real
        $retval = $this->readBinaryReal($object_length);
        break;
      case '3': // date
        $retval = $this->readBinaryDate($object_length);
        break;
      case '4': // data
        $retval = $this->readBinaryData($object_length);
        break;
      case '5': // byte string, usually utf8 encoded
        $retval = $this->readBinaryString($object_length);
        break;
      case '6': // unicode string (utf16be)
        $retval = $this->readBinaryUnicodeString($object_length);
        break;
      case 'a': // array
        $retval = $this->readBinaryArray($object_length);
        break;
      case 'd': // dictionary
        $retval = $this->readBinaryDict($object_length);
        break;
    }

    return $retval;
  }

  /**
   * Read an object type byte at position $pos, decode it and delegate to the correct reader function
   * @param integer $pos The table position in the offsets table
   * @return mixed The value of the delegate reader, so any of the CFType subclasses
   */
  function readBinaryObjectAt($pos) {
    $this->pos = $this->offsets[$pos];
    return $this->readBinaryObject();
  }

  /**
   * Parse a binary plist string
   * @return void
   * @throws IOException if read error occurs
   */
  public function parseBinaryString() {
    $this->uniqueTable = Array();
    $this->countObjects = 0;
    $this->stringSize = 0;
    $this->intSize = 0;
    $this->miscSize = 0;
    $this->objectRefs = 0;

    $this->writtenObjectCount = 0;
    $this->objectTable = Array();
    $this->objectRefSize = 0;

    $this->offsets = Array();

    // first, we read the trailer: 32 byte from the end
    $buff = substr($this->content,-32);

    if(strlen($buff) < 32) {
      throw new PListException('Error in PList format: content is less than at least necessary 32 bytes!');
    }

    $infos = unpack("x6/Coffset_size/Cobject_ref_size/x4/Nnumber_of_objects/x4/Ntop_object/x4/Ntable_offset",$buff);

    // after that, get the offset table
    $coded_offset_table = substr($this->content,$infos['table_offset'],$infos['number_of_objects'] * $infos['offset_size']);
    if(strlen($coded_offset_table) != $infos['number_of_objects'] * $infos['offset_size']) throw IOException::readError("");
    $this->countObjects = $infos['number_of_objects'];

    // decode offset table
    $formats = Array("","C*","n*",NULL,"N*");
    if($infos['offset_size'] == 3) { # since PHP does not support parenthesis in pack/unpack expressions,
                                     # "(H6)*" does not work and we have to work round this by repeating the
                                     # expression as often as it fits in the string
      $this->offsets = array(NULL);
      while($coded_offset_table) {
        $str = unpack("H6",$coded_offset_table);
        $this->offsets[] = hexdec($str[1]);
        $coded_offset_table = substr($coded_offset_table,3);
      }
    }
    else $this->offsets = unpack($formats[$infos['offset_size']],$coded_offset_table);

    $this->uniqueTable = Array();
    $this->objectRefSize = $infos['object_ref_size'];

    $top = $this->readBinaryObjectAt($infos['top_object']+1);
    $this->add($top);
  }

  /**
   * Read a binary plist stream
   * @param resource $stream The stream to read
   * @return void
   * @throws IOException if read error occurs
   */
  function readBinaryStream($stream) {
    if(($str = stream_get_contents($stream)) === false || empty($str)) {
      throw new PListException("Error reading stream!");
    }

    $this->parseBinary($str);
  }

  /**
   * parse a binary plist string
   * @param string $content The stream to read, defaults to {@link $this->content}
   * @return void
   * @throws IOException if read error occurs
   */
  function parseBinary($content=NULL) {
    if($content !== NULL) {
      $this->content = $content;
    }

    if(empty($this->content)) {
      throw new PListException("Content may not be empty!");
    }

    if(substr($this->content,0,8) != 'bplist00') {
      throw new PListException("Invalid binary string!");
    }

    $this->pos = 0;

    $this->parseBinaryString();
  }

  /**
   * Read a binary plist file
   * @param string $file The file to read
   * @return void
   * @throws IOException if read error occurs
   */
  function readBinary($file) {
    if(!($fd = fopen($file,"rb"))) {
      throw new IOException("Could not open file {$file}!");
    }

    $this->readBinaryStream($fd);
    fclose($fd);
  }

  /**
   * calculate the bytes needed for a size integer value
   * @param integer $int The integer value to calculate
   * @return integer The number of bytes needed
   */
  public static function bytesSizeInt($int) {
    $nbytes = 0;

    if($int > 0xE) $nbytes += 2; // 2 size-bytes
    if($int > 0xFF) $nbytes += 1; // 3 size-bytes
    if($int > 0xFFFF) $nbytes += 2; // 5 size-bytes

    return $nbytes;
  }

  /**
   * Calculate the byte needed for a „normal” integer value
   * @param integer $int The integer value
   * @return integer The number of bytes needed + 1 (because of the „marker byte”)
   */
  public static function bytesInt($int) {
    $nbytes = 1;

    if($int > 0xFF) $nbytes += 1; // 2 byte integer
    if($int > 0xFFFF) $nbytes += 2; // 4 byte integer
    if($int > 0xFFFFFFFF) $nbytes += 4; // 8 byte integer
    if($int < 0) $nbytes += 7; // 8 byte integer (since it is signed)

    return $nbytes + 1; // one „marker” byte
  }

  /**
   * „pack” a value (i.e. write the binary representation as big endian to a string) with the specified size
   * @param integer $nbytes The number of bytes to pack
   * @param integer $int the integer value to pack
   * @return string The packed value as string
   */
  public static function packItWithSize($nbytes,$int) {
    $formats = Array("C", "n", "N", "N");
    $format = $formats[$nbytes-1];
    $ret = '';

    if($nbytes == 3) return substr(pack($format, $int), -3);
    return pack($format, $int);
  }

  /**
   * Calculate the bytes needed to save the number of objects
   * @param integer $count_objects The number of objects
   * @return integer The number of bytes
   */
  public static function bytesNeeded($count_objects) {
    $nbytes = 0;

    while($count_objects >= 1) {
      $nbytes++;
      $count_objects /= 256;
    }

    return $nbytes;
  }

  /**
   * Code an integer to byte representation
   * @param integer $int The integer value
   * @return string The packed byte value
   */
  public static function intBytes($int) {
    $intbytes = "";

    if($int > 0xFFFF) $intbytes = "\x12".pack("N", $int); // 4 byte integer
    elseif($int > 0xFF) $intbytes = "\x11".pack("n", $int); // 2 byte integer
    else $intbytes = "\x10".pack("C", $int); // 8 byte integer

    return $intbytes;
  }

  /**
   * Code an type byte, consisting of the type marker and the length of the type
   * @param string $type The type byte value (i.e. "d" for dictionaries)
   * @param integer $type_len The length of the type
   * @return string The packed type byte value
   */
  public static function typeBytes($type,$type_len) {
    $optional_int = "";

    if($type_len < 15) $type .= sprintf("%x", $type_len);
    else {
      $type .= "f";
      $optional_int = self::intBytes($type_len);
    }

    return pack("H*", $type).$optional_int;
  }

  /**
   * Count number of objects and create a unique table for strings
   * @param $value The value to count and unique
   * @return void
   */
  protected function uniqueAndCountValues($value) {
    // no uniquing for other types than CFString and CFData
    if($value instanceof CFNumber) {
      $val = $value->getValue();
      if(intval($val) == $val && !is_float($val) && strpos($val,'.') === false) $this->intSize += self::bytesInt($val);
      else $this->miscSize += 9; // 9 bytes (8 + marker byte) for real
      $this->countObjects++;
      return;
    }
    elseif($value instanceof CFDate) {
      $this->miscSize += 9; // since date in plist is real, we need 9 byte (8 + marker byte)
      $this->countObjects++;
      return;
    }
    elseif($value instanceof CFBoolean) {
      $this->countObjects++;
      $this->miscSize += 1;
      return;
    }
    elseif($value instanceof CFArray) {
      $cnt = 0;
      foreach($value as $v) {
        ++$cnt;
        $this->uniqueAndCountValues($v);
        $this->objectRefs++; // each array member is a ref
      }

      $this->countObjects++;
      $this->intSize += self::bytesSizeInt($cnt);
      $this->miscSize++; // marker byte for array
      return;
    }
    elseif($value instanceof CFDictionary) {
      $cnt = 0;
      foreach($value as $k => $v) {
        ++$cnt;
        if(!isset($this->uniqueTable[$k])) {
          $this->uniqueTable[$k] = 0;
          $len = self::binaryStrlen($k);
          $this->stringSize += $len + 1;
          $this->intSize += self::bytesSizeInt(self::charsetStrlen($k,'UTF-8'));
        }

        $this->objectRefs += 2; // both, key and value, are refs
        $this->uniqueTable[$k]++;
        $this->uniqueAndCountValues($v);
      }

      $this->countObjects++;
      $this->miscSize++; // marker byte for dict
      $this->intSize += self::bytesSizeInt($cnt);
      return;
    }
    elseif($value instanceOf CFData) {
      $val = $value->getValue();
      $len = strlen($val);
      $this->intSize += self::bytesSizeInt($len);
      $this->miscSize += $len + 1;
      $this->countObjects++;
      return;
    }
    else $val = $value->getValue();

    if(!isset($this->uniqueTable[$val])) {
      $this->uniqueTable[$val] = 0;
      $len = self::binaryStrlen($val);
      $this->stringSize += $len + 1;
      $this->intSize += self::bytesSizeInt(self::charsetStrlen($val,'UTF-8'));
    }
    $this->uniqueTable[$val]++;
  }

  /**
   * Convert CFPropertyList to binary format; since we have to count our objects we simply unique CFDictionary and CFArray
   * @return string The binary plist content
   */
  public function toBinary() {
    $this->uniqueTable = Array();
    $this->countObjects = 0;
    $this->stringSize = 0;
    $this->intSize = 0;
    $this->miscSize = 0;
    $this->objectRefs = 0;

    $this->writtenObjectCount = 0;
    $this->objectTable = Array();
    $this->objectRefSize = 0;

    $this->offsets = Array();

    $binary_str = "bplist00";
    $value = $this->getValue(true);
    $this->uniqueAndCountValues($value);

    $this->countObjects += count($this->uniqueTable);
    $this->objectRefSize = self::bytesNeeded($this->countObjects);
    $file_size = $this->stringSize + $this->intSize + $this->miscSize + $this->objectRefs * $this->objectRefSize + 40;
    $offset_size = self::bytesNeeded($file_size);
    $table_offset = $file_size - 32;

    $this->objectTable = Array();
    $this->writtenObjectCount = 0;
    $this->uniqueTable = Array(); // we needed it to calculate several values
    $value->toBinary($this);

    $object_offset = 8;
    $offsets = Array();

    for($i=0;$i<count($this->objectTable);++$i) {
      $binary_str .= $this->objectTable[$i];
      $offsets[$i] = $object_offset;
      $object_offset += strlen($this->objectTable[$i]);
    }

    for($i=0;$i<count($offsets);++$i) {
      $binary_str .= self::packItWithSize($offset_size, $offsets[$i]);
    }


    $binary_str .= pack("x6CC", $offset_size, $this->objectRefSize);
    $binary_str .= pack("x4N", $this->countObjects);
    $binary_str .= pack("x4N", 0);
    $binary_str .= pack("x4N", $table_offset);

    return $binary_str;
  }

  /**
   * Counts the number of bytes the string will have when coded; utf-16be if non-ascii characters are present.
   * @param string $val The string value
   * @return integer The length of the coded string in bytes
   */
  protected static function binaryStrlen($val) {
    for($i=0;$i<strlen($val);++$i) {
      if(ord($val{$i}) >= 128) {
        $val = self::convertCharset($val, 'UTF-8', 'UTF-16BE');
        return strlen($val);
      }
    }

    return strlen($val);
  }

  /**
   * Uniques and transforms a string value to binary format and adds it to the object table
   * @param string $val The string value
   * @return integer The position in the object table
   */
  public function stringToBinary($val) {
    $saved_object_count = -1;

    if(!isset($this->uniqueTable[$val])) {
      $saved_object_count = $this->writtenObjectCount++;
      $this->uniqueTable[$val] = $saved_object_count;
      $utf16 = false;

      for($i=0;$i<strlen($val);++$i) {
        if(ord($val{$i}) >= 128) {
          $utf16 = true;
          break;
        }
      }

      if($utf16) {
        $bdata = self::typeBytes("6", mb_strlen($val,'UTF-8')); // 6 is 0110, unicode string (utf16be)
        $val = self::convertCharset($val, 'UTF-8', 'UTF-16BE');
        $this->objectTable[$saved_object_count] = $bdata.$val;
      }
      else {
        $bdata = self::typeBytes("5", strlen($val)); // 5 is 0101 which is an ASCII string (seems to be ASCII encoded)
        $this->objectTable[$saved_object_count] = $bdata.$val;
      }
    }
    else $saved_object_count = $this->uniqueTable[$val];

    return $saved_object_count;
  }

  /**
   * Codes an integer to binary format
   * @param integer $value The integer value
   * @return string the coded integer
   */
  protected function intToBinary($value) {
    $nbytes = 0;
    if($value > 0xFF) $nbytes = 1; // 1 byte integer
    if($value > 0xFFFF) $nbytes += 1; // 4 byte integer
    if($value > 0xFFFFFFFF) $nbytes += 1; // 8 byte integer
    if($value < 0) $nbytes = 3; // 8 byte integer, since signed

    $bdata = self::typeBytes("1", $nbytes); // 1 is 0001, type indicator for integer
    $buff = "";

    if($nbytes < 3) {
      if($nbytes == 0) $fmt = "C";
      elseif($nbytes == 1) $fmt = "n";
      else $fmt = "N";

      $buff = pack($fmt, $value);
    }
    else {
      if(PHP_INT_SIZE > 4) {
        // 64 bit signed integer; we need the higher and the lower 32 bit of the value
        $high_word = $value >> 32;
        $low_word = $value & 0xFFFFFFFF;
      }
      else {
        // since PHP can only handle 32bit signed, we can only get 32bit signed values at this point - values above 0x7FFFFFFF are
        // floats. So we ignore the existance of 64bit on non-64bit-machines
        if($value < 0) $high_word = 0xFFFFFFFF;
        else $high_word = 0;
        $low_word = $value;
      }
      $buff = pack("N", $high_word).pack("N", $low_word);
    }

    return $bdata.$buff;
  }

  /**
   * Codes a real value to binary format
   * @param float $val The real value
   * @return string The coded real
   */
  protected function realToBinary($val) {
    $bdata = self::typeBytes("2", 3); // 2 is 0010, type indicator for reals
    return $bdata.strrev(pack("d", (float)$val));
  }

  /**
   * Converts a numeric value to binary and adds it to the object table
   * @param numeric $value The numeric value
   * @return integer The position in the object table
   */
  public function numToBinary($value) {
    $saved_object_count = $this->writtenObjectCount++;

    $val = "";
    if(intval($value) == $value && !is_float($value) && strpos($value,'.') === false) $val = $this->intToBinary($value);
    else $val = $this->realToBinary($value);

    $this->objectTable[$saved_object_count] = $val;
    return $saved_object_count;
  }

  /**
   * Convert date value (apple format) to binary and adds it to the object table
   * @param integer $value The date value
   * @return integer The position of the coded value in the object table
   */
  public function dateToBinary($val) {
    $saved_object_count = $this->writtenObjectCount++;

    $hour = gmdate("H",$val);
    $min = gmdate("i",$val);
    $sec = gmdate("s",$val);
    $mday = gmdate("j",$val);
    $mon = gmdate("n",$val);
    $year = gmdate("Y",$val);

    $val = gmmktime($hour,$min,$sec,$mon,$mday,$year) - CFDate::DATE_DIFF_APPLE_UNIX; // CFDate is a real, number of seconds since 01/01/2001 00:00:00 GMT

    $bdata = self::typeBytes("3", 3); // 3 is 0011, type indicator for date
    $this->objectTable[$saved_object_count] = $bdata.strrev(pack("d", $val));

    return $saved_object_count;
  }

  /**
   * Convert a bool value to binary and add it to the object table
   * @param bool $val The boolean value
   * @return integer The position in the object table
   */
  public function boolToBinary($val) {
    $saved_object_count = $this->writtenObjectCount++;
    $this->objectTable[$saved_object_count] = $val ? "\x9" : "\x8"; // 0x9 is 1001, type indicator for true; 0x8 is 1000, type indicator for false
    return $saved_object_count;
  }

  /**
   * Convert data value to binary format and add it to the object table
   * @param string $val The data value
   * @return integer The position in the object table
   */
  public function dataToBinary($val) {
    $saved_object_count = $this->writtenObjectCount++;

    $bdata = self::typeBytes("4", strlen($val)); // a is 1000, type indicator for data
    $this->objectTable[$saved_object_count] = $bdata.$val;

    return $saved_object_count;
  }

  /**
   * Convert array to binary format and add it to the object table
   * @param CFArray $val The array to convert
   * @return integer The position in the object table
   */
  public function arrayToBinary($val) {
    $saved_object_count = $this->writtenObjectCount++;

    $bdata = self::typeBytes("a", count($val->getValue())); // a is 1010, type indicator for arrays

    foreach($val as $v) {
      $bval = $v->toBinary($this);
      $bdata .= self::packItWithSize($this->objectRefSize, $bval);
    }

    $this->objectTable[$saved_object_count] = $bdata;
    return $saved_object_count;
  }

  /**
   * Convert dictionary to binary format and add it to the object table
   * @param CFDictionary $val The dict to convert
   * @return integer The position in the object table
   */
  public function dictToBinary($val) {
    $saved_object_count = $this->writtenObjectCount++;
    $bdata = self::typeBytes("d", count($val->getValue())); // d=1101, type indicator for dictionary

    foreach($val as $k => $v) {
      $str = new CFString($k);
      $key = $str->toBinary($this);
      $bdata .= self::packItWithSize($this->objectRefSize, $key);
    }

    foreach($val as $k => $v) {
      $bval = $v->toBinary($this);
      $bdata .= self::packItWithSize($this->objectRefSize, $bval);
    }

    $this->objectTable[$saved_object_count] = $bdata;
    return $saved_object_count;
  }

}


/**
 * Data-Types for CFPropertyList as defined by Apple.
 * {@link http://developer.apple.com/documentation/Darwin/Reference/ManPages/man5/plist.5.html Property Lists}
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 * @version $Id$
 */

/**
 * Base-Class of all CFTypes used by CFPropertyList
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 * @version $Id$
 * @example example-create-01.php Using the CFPropertyList API
 * @example example-create-02.php Using CFPropertyList::guess()
 * @example example-create-03.php Using CFPropertyList::guess() with {@link CFDate} and {@link CFData}
 */
abstract class CFType {
  /**
   * CFType nodes
   * @var array
   */
  protected $value = null;

  /**
   * Create new CFType.
   * @param mixed $value Value of CFType
   */
  public function __construct($value=null) {
    $this->setValue($value);
  }

  /************************************************************************************************
   *    M A G I C   P R O P E R T I E S
   ************************************************************************************************/

  /**
   * Get the CFType's value
   * @return mixed CFType's value
   */
  public function getValue() {
    return $this->value;
  }

  /**
   * Set the CFType's value
   * @return void
   */
  public function setValue($value) {
    $this->value = $value;
  }

  /************************************************************************************************
   *    S E R I A L I Z I N G
   ************************************************************************************************/

  /**
   * Get XML-Node.
   * @param DOMDocument $doc DOMDocument to create DOMNode in
   * @param string $nodeName Name of element to create
   * @return DOMNode Node created based on CType
   * @uses $value as nodeValue
   */
  public function toXML(DOMDocument $doc, $nodeName) {
    $node = $doc->createElement($nodeName);

    if($this->value !== '') {
      $text = $doc->createTextNode($this->value);
      $node->appendChild($text);
    }

    return $node;
  }

  /**
   * convert value to binary representation
   * @param CFBinaryPropertyList The binary property list object
   * @return The offset in the object table
   */
  public abstract function toBinary(CFBinaryPropertyList &$bplist);

  /**
   * Get CFType's value.
   * @return mixed primitive value
   * @uses $value for retrieving primitive of CFType
   */
  public function toArray() {
    return $this->getValue();
  }

}

/**
 * String Type of CFPropertyList
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 */
class CFString extends CFType {
  /**
   * Get XML-Node.
   * @param DOMDocument $doc DOMDocument to create DOMNode in
   * @param string $nodeName For compatibility reasons; just ignore it
   * @return DOMNode &lt;string&gt;-Element
   */
  public function toXML(DOMDocument $doc,$nodeName="") {
    return parent::toXML($doc, 'string');
  }

  /**
   * convert value to binary representation
   * @param CFBinaryPropertyList The binary property list object
   * @return The offset in the object table
   */
  public function toBinary(CFBinaryPropertyList &$bplist) {
    return $bplist->stringToBinary($this->value);
  }
}

/**
 * Number Type of CFPropertyList
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 */
class CFNumber extends CFType {
  /**
   * Get XML-Node.
   * Returns &lt;real&gt; if $value is a float, &lt;integer&gt; if $value is an integer.
   * @param DOMDocument $doc DOMDocument to create DOMNode in
   * @param string $nodeName For compatibility reasons; just ignore it
   * @return DOMNode &lt;real&gt; or &lt;integer&gt;-Element
   */
  public function toXML(DOMDocument $doc,$nodeName="") {
    $ret = 'real';
    if(intval($this->value) == $this->value && !is_float($this->value) && strpos($this->value,'.') === false) {
      $this->value = intval($this->value);
      $ret = 'integer';
    }
    return parent::toXML($doc, $ret);
  }

  /**
   * convert value to binary representation
   * @param CFBinaryPropertyList The binary property list object
   * @return The offset in the object table
   */
  public function toBinary(CFBinaryPropertyList &$bplist) {
    return $bplist->numToBinary($this->value);
  }
}

/**
 * Date Type of CFPropertyList
 * Note: CFDate uses Unix timestamp (epoch) to store dates internally
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 */
class CFDate extends CFType {
  const TIMESTAMP_APPLE = 0;
  const TIMESTAMP_UNIX  = 1;
  const DATE_DIFF_APPLE_UNIX = 978307200;

  /**
   * Create new Date CFType.
   * @param integer $value timestamp to set
   * @param integer $format format the timestamp is specified in, use {@link TIMESTAMP_APPLE} or {@link TIMESTAMP_UNIX}, defaults to {@link TIMESTAMP_APPLE}
   * @uses setValue() to convert the timestamp
   */
  function __construct($value,$format=CFDate::TIMESTAMP_UNIX) {
    $this->setValue($value,$format);
  }

  /**
   * Set the Date CFType's value.
   * @param integer $value timestamp to set
   * @param integer $format format the timestamp is specified in, use {@link TIMESTAMP_APPLE} or {@link TIMESTAMP_UNIX}, defaults to {@link TIMESTAMP_UNIX}
   * @return void
   * @uses TIMESTAMP_APPLE to determine timestamp type
   * @uses TIMESTAMP_UNIX to determine timestamp type
   * @uses DATE_DIFF_APPLE_UNIX to convert Apple-timestamp to Unix-timestamp
   */
  function setValue($value,$format=CFDate::TIMESTAMP_UNIX) {
    if($format == CFDate::TIMESTAMP_UNIX) $this->value = $value;
    else $this->value = $value + CFDate::DATE_DIFF_APPLE_UNIX;
  }

  /**
   * Get the Date CFType's value.
   * @param integer $format format the timestamp is specified in, use {@link TIMESTAMP_APPLE} or {@link TIMESTAMP_UNIX}, defaults to {@link TIMESTAMP_UNIX}
   * @return integer Unix timestamp
   * @uses TIMESTAMP_APPLE to determine timestamp type
   * @uses TIMESTAMP_UNIX to determine timestamp type
   * @uses DATE_DIFF_APPLE_UNIX to convert Unix-timestamp to Apple-timestamp
   */
  function getValue($format=CFDate::TIMESTAMP_UNIX) {
    if($format == CFDate::TIMESTAMP_UNIX) return $this->value;
    else return $this->value - CFDate::DATE_DIFF_APPLE_UNIX;
  }

  /**
   * Get XML-Node.
   * @param DOMDocument $doc DOMDocument to create DOMNode in
   * @param string $nodeName For compatibility reasons; just ignore it
   * @return DOMNode &lt;date&gt;-Element
   */
  public function toXML(DOMDocument $doc,$nodeName="") {
    $text = $doc->createTextNode(gmdate("Y-m-d\TH:i:s\Z",$this->getValue()));
    $node = $doc->createElement("date");
    $node->appendChild($text);
    return $node;
  }

  /**
   * convert value to binary representation
   * @param CFBinaryPropertyList The binary property list object
   * @return The offset in the object table
   */
  public function toBinary(CFBinaryPropertyList &$bplist) {
    return $bplist->dateToBinary($this->value);
  }

  /**
   * Create a UNIX timestamp from a PList date string
   * @param string $val The date string (e.g. "2009-05-13T20:23:43Z")
   * @return integer The UNIX timestamp
   * @throws PListException when encountering an unknown date string format
   */
  public static function dateValue($val) {
    //2009-05-13T20:23:43Z
    if(!preg_match('/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z/',$val,$matches)) throw new PListException("Unknown date format: $val");
    return gmmktime($matches[4],$matches[5],$matches[6],$matches[2],$matches[3],$matches[1]);
  }
}

/**
 * Boolean Type of CFPropertyList
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 */
class CFBoolean extends CFType {
  /**
   * Get XML-Node.
   * Returns &lt;true&gt; if $value is a true, &lt;false&gt; if $value is false.
   * @param DOMDocument $doc DOMDocument to create DOMNode in
   * @param string $nodeName For compatibility reasons; just ignore it
   * @return DOMNode &lt;true&gt; or &lt;false&gt;-Element
   */
  public function toXML(DOMDocument $doc,$nodeName="") {
    return $doc->createElement($this->value ? 'true' : 'false');
  }

  /**
   * convert value to binary representation
   * @param CFBinaryPropertyList The binary property list object
   * @return The offset in the object table
   */
  public function toBinary(CFBinaryPropertyList &$bplist) {
    return $bplist->boolToBinary($this->value);
  }

}

/**
 * Data Type of CFPropertyList
 * Note: Binary data is base64-encoded.
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 */
class CFData extends CFType {
  /**
   * Create new Data CFType
   * @param string $value data to be contained by new object
   * @param boolean $already_coded if true $value will not be base64-encoded, defaults to false
   */
  public function __construct($value=null,$already_coded=false) {
    if($already_coded) $this->value = $value;
    else $this->setValue($value);
  }

  /**
   * Set the CFType's value and base64-encode it.
   * <b>Note:</b> looks like base64_encode has troubles with UTF-8 encoded strings
   * @return void
   */
  public function setValue($value) {
    //if(function_exists('mb_check_encoding') && mb_check_encoding($value, 'UTF-8')) $value = utf8_decode($value);
    $this->value = base64_encode($value);
  }

  /**
   * Get base64 encoded data
   * @return string The base64 encoded data value
   */
  public function getCodedValue() {
    return $this->value;
  }

  /**
   * Get the base64-decoded CFType's value.
   * @return mixed CFType's value
   */
  public function getValue() {
    return base64_decode($this->value);
  }

  /**
   * Get XML-Node.
   * @param DOMDocument $doc DOMDocument to create DOMNode in
   * @param string $nodeName For compatibility reasons; just ignore it
   * @return DOMNode &lt;data&gt;-Element
   */
  public function toXML(DOMDocument $doc,$nodeName="") {
    return parent::toXML($doc, 'data');
  }

  /**
   * convert value to binary representation
   * @param CFBinaryPropertyList The binary property list object
   * @return The offset in the object table
   */
  public function toBinary(CFBinaryPropertyList &$bplist) {
    return $bplist->dataToBinary($this->getValue());
  }
}

/**
 * Array Type of CFPropertyList
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 */
class CFArray extends CFType implements Iterator, ArrayAccess {
  /**
   * Position of iterator {@link http://php.net/manual/en/class.iterator.php}
   * @var integer
   */
  protected $iteratorPosition = 0;


  /**
   * Create new CFType.
   * @param array $value Value of CFType
   */
  public function __construct($value=array()) {
    $this->value = $value;
  }

  /**
   * Set the CFType's value
   * <b>Note:</b> this dummy does nothing
   * @return void
   */
  public function setValue($value) {
  }

  /**
   * Add CFType to collection.
   * @param CFType $value CFType to add to collection, defaults to null which results in an empty {@link CFString}
   * @return void
   * @uses $value for adding $value
   */
  public function add(CFType $value=null) {
    // anything but CFType is null, null is an empty string - sad but true
    if( !$value )
      $value = new CFString();

    $this->value[] = $value;
  }

  /**
   * Get CFType from collection.
   * @param integer $key Key of CFType to retrieve from collection
   * @return CFType CFType found at $key, null else
   * @uses $value for retrieving CFType of $key
   */
  public function get($key) {
    if(isset($this->value[$key])) return $this->value[$key];
    return null;
  }

  /**
   * Remove CFType from collection.
   * @param integer $key Key of CFType to removes from collection
   * @return CFType removed CFType, null else
   * @uses $value for removing CFType of $key
   */
  public function del($key) {
    if(isset($this->value[$key])) unset($this->value[$key]);
  }


  /************************************************************************************************
   *    S E R I A L I Z I N G
   ************************************************************************************************/

  /**
   * Get XML-Node.
   * @param DOMDocument $doc DOMDocument to create DOMNode in
   * @param string $nodeName For compatibility reasons; just ignore it
   * @return DOMNode &lt;array&gt;-Element
   */
  public function toXML(DOMDocument $doc,$nodeName="") {
    $node = $doc->createElement('array');

    foreach($this->value as $value) $node->appendChild($value->toXML($doc));
    return $node;
  }

  /**
   * convert value to binary representation
   * @param CFBinaryPropertyList The binary property list object
   * @return The offset in the object table
   */
  public function toBinary(CFBinaryPropertyList &$bplist) {
    return $bplist->arrayToBinary($this);
  }

  /**
   * Get CFType's value.
   * @return array primitive value
   * @uses $value for retrieving primitive of CFType
   */
  public function toArray() {
    $a = array();
    foreach($this->value as $value) $a[] = $value->toArray();
    return $a;
  }


  /************************************************************************************************
   *    I T E R A T O R   I N T E R F A C E
   ************************************************************************************************/

  /**
   * Rewind {@link $iteratorPosition} to first position (being 0)
   * @link http://php.net/manual/en/iterator.rewind.php
   * @return void
   * @uses $iteratorPosition set to 0
   */
  public function rewind() {
    $this->iteratorPosition = 0;
  }

  /**
   * Get Iterator's current {@link CFType} identified by {@link $iteratorPosition}
   * @link http://php.net/manual/en/iterator.current.php
   * @return CFType current Item
   * @uses $iteratorPosition identify current key
   */
  public function current() {
    return $this->value[$this->iteratorPosition];
  }

  /**
   * Get Iterator's current key identified by {@link $iteratorPosition}
   * @link http://php.net/manual/en/iterator.key.php
   * @return string key of the current Item
   * @uses $iteratorPosition identify current key
   */
  public function key() {
    return $this->iteratorPosition;
  }

  /**
   * Increment {@link $iteratorPosition} to address next {@see CFType}
   * @link http://php.net/manual/en/iterator.next.php
   * @return void
   * @uses $iteratorPosition increment by 1
   */
  public function next() {
    $this->iteratorPosition++;
  }

  /**
   * Test if {@link $iteratorPosition} addresses a valid element of {@link $value}
   * @link http://php.net/manual/en/iterator.valid.php
   * @return boolean true if current position is valid, false else
   * @uses $iteratorPosition test if within {@link $iteratorKeys}
   * @uses $iteratorPosition test if within {@link $value}
   */
  public function valid() {
    return isset($this->value[$this->iteratorPosition]);
  }

  /************************************************************************************************
   *    ArrayAccess   I N T E R F A C E
   ************************************************************************************************/

  /**
   * Determine if the array's key exists
   * @param string $key the key to check
   * @return bool true if the offset exists, false if not
   * @link http://php.net/manual/en/arrayaccess.offsetexists.php
   * @uses $value to check if $key exists
   * @author Sean Coates <sean@php.net>
   */
  public function offsetExists($key) {
    return isset($this->value[$key]);
  }

  /**
   * Fetch a specific key from the CFArray
   * @param string $key the key to check
   * @return mixed the value associated with the key; null if the key is not found
   * @link http://php.net/manual/en/arrayaccess.offsetget.php
   * @uses get() to get the key's value
   * @author Sean Coates <sean@php.net>
   */
  public function offsetGet($key) {
    return $this->get($key);
  }

  /**
   * Set a value in the array
   * @param string $key the key to set
   * @param string $value the value to set
   * @return void
   * @link http://php.net/manual/en/arrayaccess.offsetset.php
   * @uses setValue() to set the key's new value
   * @author Sean Coates <sean@php.net>
   */
  public function offsetSet($key, $value) {
    return $this->setValue($value);
  }

  /**
   * Unsets a value in the array
   * <b>Note:</b> this dummy does nothing
   * @param string $key the key to set
   * @return void
   * @link http://php.net/manual/en/arrayaccess.offsetunset.php
   * @author Sean Coates <sean@php.net>
   */
  public function offsetUnset($key) {

  }


}

/**
 * Array Type of CFPropertyList
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @subpackage plist.types
 */
class CFDictionary extends CFType implements Iterator {
  /**
   * Position of iterator {@link http://php.net/manual/en/class.iterator.php}
   * @var integer
   */
  protected $iteratorPosition = 0;

  /**
   * List of Keys for numerical iterator access {@link http://php.net/manual/en/class.iterator.php}
   * @var array
   */
  protected $iteratorKeys = null;


  /**
   * Create new CFType.
   * @param array $value Value of CFType
   */
  public function __construct($value=array()) {
    $this->value = $value;
  }

  /**
   * Set the CFType's value
   * <b>Note:</b> this dummy does nothing
   * @return void
   */
  public function setValue($value) {
  }

  /**
   * Add CFType to collection.
   * @param string $key Key to add to collection
   * @param CFType $value CFType to add to collection, defaults to null which results in an empty {@link CFString}
   * @return void
   * @uses $value for adding $key $value pair
   */
  public function add($key, CFType $value=null) {
    // anything but CFType is null, null is an empty string - sad but true
    if( !$value )
      $value = new CFString();

    $this->value[$key] = $value;
  }

  /**
   * Get CFType from collection.
   * @param string $key Key of CFType to retrieve from collection
   * @return CFType CFType found at $key, null else
   * @uses $value for retrieving CFType of $key
   */
  public function get($key) {
    if(isset($this->value[$key])) return $this->value[$key];
    return null;
  }

  /**
   * Generic getter (magic)
   * @param integer $key Key of CFType to retrieve from collection
   * @return CFType CFType found at $key, null else
   * @link http://php.net/oop5.overloading
   * @uses get() to retrieve the key's value
   * @author Sean Coates <sean@php.net>
   */
  public function __get($key) {
    return $this->get($key);
  }

  /**
   * Remove CFType from collection.
   * @param string $key Key of CFType to removes from collection
   * @return CFType removed CFType, null else
   * @uses $value for removing CFType of $key
   */
  public function del($key) {
    if(isset($this->value[$key])) unset($this->value[$key]);
  }


  /************************************************************************************************
   *    S E R I A L I Z I N G
   ************************************************************************************************/

  /**
   * Get XML-Node.
   * @param DOMDocument $doc DOMDocument to create DOMNode in
   * @param string $nodeName For compatibility reasons; just ignore it
   * @return DOMNode &lt;dict&gt;-Element
   */
  public function toXML(DOMDocument $doc,$nodeName="") {
    $node = $doc->createElement('dict');

    foreach($this->value as $key => $value) {
      $node->appendChild($doc->createElement('key', $key));
      $node->appendChild($value->toXML($doc));
    }

    return $node;
  }

  /**
   * convert value to binary representation
   * @param CFBinaryPropertyList The binary property list object
   * @return The offset in the object table
   */
  public function toBinary(CFBinaryPropertyList &$bplist) {
    return $bplist->dictToBinary($this);
  }

  /**
   * Get CFType's value.
   * @return array primitive value
   * @uses $value for retrieving primitive of CFType
   */
  public function toArray() {
    $a = array();

    foreach($this->value as $key => $value) $a[$key] = $value->toArray();
    return $a;
  }


  /************************************************************************************************
   *    I T E R A T O R   I N T E R F A C E
   ************************************************************************************************/

  /**
   * Rewind {@link $iteratorPosition} to first position (being 0)
   * @link http://php.net/manual/en/iterator.rewind.php
   * @return void
   * @uses $iteratorPosition set to 0
   * @uses $iteratorKeys store keys of {@link $value}
   */
  public function rewind() {
    $this->iteratorPosition = 0;
    $this->iteratorKeys = array_keys($this->value);
  }

  /**
   * Get Iterator's current {@link CFType} identified by {@link $iteratorPosition}
   * @link http://php.net/manual/en/iterator.current.php
   * @return CFType current Item
   * @uses $iteratorPosition identify current key
   * @uses $iteratorKeys identify current value
   */
  public function current() {
    return $this->value[$this->iteratorKeys[$this->iteratorPosition]];
  }

  /**
   * Get Iterator's current key identified by {@link $iteratorPosition}
   * @link http://php.net/manual/en/iterator.key.php
   * @return string key of the current Item
   * @uses $iteratorPosition identify current key
   * @uses $iteratorKeys identify current value
   */
  public function key() {
    return $this->iteratorKeys[$this->iteratorPosition];
  }

  /**
   * Increment {@link $iteratorPosition} to address next {@see CFType}
   * @link http://php.net/manual/en/iterator.next.php
   * @return void
   * @uses $iteratorPosition increment by 1
   */
  public function next() {
    $this->iteratorPosition++;
  }

  /**
   * Test if {@link $iteratorPosition} addresses a valid element of {@link $value}
   * @link http://php.net/manual/en/iterator.valid.php
   * @return boolean true if current position is valid, false else
   * @uses $iteratorPosition test if within {@link $iteratorKeys}
   * @uses $iteratorPosition test if within {@link $value}
   */
  public function valid() {
    return isset($this->iteratorKeys[$this->iteratorPosition]) && isset($this->value[$this->iteratorKeys[$this->iteratorPosition]]);
  }

}


 /**
  * CFTypeDetector
  * Interface for converting native PHP data structures to CFPropertyList objects.
  * @author Rodney Rehm <rodney.rehm@medialize.de>
  * @author Christian Kruse <cjk@wwwtech.de>
  * @package plist
  * @subpackage plist.types
  * @example example-create-02.php Using {@link CFTypeDetector}
  * @example example-create-03.php Using {@link CFTypeDetector} with {@link CFDate} and {@link CFData}
  * @example example-create-04.php Using and extended {@link CFTypeDetector}
  */

class CFTypeDetector {

  /**
   * flag stating if all arrays should automatically be converted to {@link CFDictionary}
   * @var boolean
   */
  protected $autoDictionary = false;

  /**
   * flag stating if exceptions should be suppressed or thrown
   * @var boolean
   */
  protected $suppressExceptions = false;

  /**
   * name of a method that will be used for array to object conversations
   * @var callable
   */
  protected $objectToArrayMethod = null;
  
  /**
   * flag stating if "123.23" should be converted to float (true) or preserved as string (false)
   * @var boolean
   */
  protected $castNumericStrings = true;


  /**
   * Create new CFTypeDetector
   * @param array $options Configuration for casting values [autoDictionary, suppressExceptions, objectToArrayMethod, castNumericStrings]
   */
  public function __construct(array $options=array()) {
    //$autoDicitionary=false,$suppressExceptions=false,$objectToArrayMethod=null
    foreach ($options as $key => $value) {
      if (property_exists($this, $key)) {
        $this->$key = $value;
      }
    }
  }

  /**
   * Determine if an array is associative or numerical.
   * Numerical Arrays have incrementing index-numbers that don't contain gaps.
   * @param array $value Array to check indexes of
   * @return boolean true if array is associative, false if array has numeric indexes
   */
  protected function isAssociativeArray($value) {
    $numericKeys = true;
    $i = 0;
    foreach($value as $key => $v) {
      if($i !== $key) {
        $numericKeys = false;
        break;
      }
      $i++;
    }
    return !$numericKeys;
  }

  /**
   * Get the default value
   * @return CFType the default value to return if no suitable type could be determined
   */
  protected function defaultValue() {
    return new CFString();
  }

  /**
   * Create CFType-structure by guessing the data-types.
   * {@link CFArray}, {@link CFDictionary}, {@link CFBoolean}, {@link CFNumber} and {@link CFString} can be created, {@link CFDate} and {@link CFData} cannot.
   * <br /><b>Note:</b>Distinguishing between {@link CFArray} and {@link CFDictionary} is done by examining the keys.
   * Keys must be strictly incrementing integers to evaluate to a {@link CFArray}.
   * Since PHP does not offer a function to test for associative arrays,
   * this test causes the input array to be walked twice and thus work rather slow on large collections.
   * If you work with large arrays and can live with all arrays evaluating to {@link CFDictionary},
   * feel free to set the appropriate flag.
   * <br /><b>Note:</b> If $value is an instance of CFType it is simply returned.
   * <br /><b>Note:</b> If $value is neither a CFType, array, numeric, boolean nor string, it is omitted.
   * @param mixed $value Value to convert to CFType
   * @param boolean $autoDictionary if true {@link CFArray}-detection is bypassed and arrays will be returned as {@link CFDictionary}.
   * @return CFType CFType based on guessed type
   * @uses isAssociativeArray() to check if an array only has numeric indexes
   */
  public function toCFType($value) {
    switch(true) {
      case $value instanceof CFType:
        return $value;
      break;

      case is_object($value):
        // DateTime should be CFDate
        if(class_exists( 'DateTime' ) && $value instanceof DateTime){
          return new CFDate($value->getTimestamp());
        }

        // convert possible objects to arrays, arrays will be arrays
        if($this->objectToArrayMethod && is_callable(array($value, $this->objectToArrayMethod))){
          $value = call_user_func( array( $value, $this->objectToArrayMethod ) );
        }

        if(!is_array($value)){
          if($this->suppressExceptions)
            return $this->defaultValue();

          throw new PListException('Could not determine CFType for object of type '. get_class($value));
        }
      /* break; omitted */

      case $value instanceof Iterator:
      case is_array($value):
        // test if $value is simple or associative array
        if(!$this->autoDictionary) {
          if(!$this->isAssociativeArray($value)) {
            $t = new CFArray();
            foreach($value as $v) $t->add($this->toCFType($v));
            return $t;
          }
        }

        $t = new CFDictionary();
        foreach($value as $k => $v) $t->add($k, $this->toCFType($v));

        return $t;
      break;

      case is_bool($value):
        return new CFBoolean($value);
      break;

      case is_null($value):
        return new CFString();
      break;

      case is_resource($value):
        if ($this->suppressExceptions) {
          return $this->defaultValue();
        }

        throw new PListException('Could not determine CFType for resource of type '. get_resource_type($value));
      break;

      case is_numeric($value):
        if (!$this->castNumericStrings && is_string($value)) {
          return new CFString($value);
        }
        
        return new CFNumber($value);
      break;
      
      case is_string($value):
        return new CFString($value);
      break;

      default:
        if ($this->suppressExceptions) {
          return $this->defaultValue();
        }

        throw new PListException('Could not determine CFType for '. gettype($value));
      break;
    }
  }

}


/**
 * CFPropertyList
 * {@link http://developer.apple.com/documentation/Darwin/Reference/ManPages/man5/plist.5.html Property Lists}
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @version $Id$
 */

/**
 * Basic Input / Output Exception
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 */
class IOException extends \Exception {
  /**
   * Flag telling the File could not be found
   */
  const NOT_FOUND = 1;
  
  /**
   * Flag telling the File is not readable
   */
  const NOT_READABLE = 2;
  
  /**
   * Flag telling the File is not writable
   */
  const NOT_WRITABLE = 3;

  /**
   * Flag telling there was a read error
   */
  const READ_ERROR = 4;

  /**
   * Flag telling there was a read error
   */
  const WRITE_ERROR = 5;

  /**
   * Create new IOException
   * @param string $path Source of the problem
   * @param integer $type Type of the problem
   */
  public function __construct($path, $type=null) {
    parent::__construct( $path, $type );
  }
  
  /**
   * Create new FileNotFound-Exception
   * @param string $path Source of the problem
   * @return IOException new FileNotFound-Exception
   */
  public static function notFound($path) {
    return new IOException( $path, self::NOT_FOUND );
  }

  /**
   * Create new FileNotReadable-Exception
   * @param string $path Source of the problem
   * @return IOException new FileNotReadable-Exception
   */
  public static function notReadable($path) {
    return new IOException( $path, self::NOT_READABLE );
  }

  /**
   * Create new FileNotWritable-Exception
   * @param string $path Source of the problem
   * @return IOException new FileNotWritable-Exception
   */
  public static function notWritable($path) {
    return new IOException( $path, self::NOT_WRITABLE );
  }

  /**
   * Create new ReadError-Exception
   * @param string $path Source of the problem
   * @return IOException new ReadError-Exception
   */
  public static function readError($path) {
    return new IOException( $path, self::READ_ERROR );
  }

  /**
   * Create new WriteError-Exception
   * @param string $path Source of the problem
   * @return IOException new WriteError-Exception
   */
  public static function writeError($path) {
    return new IOException( $path, self::WRITE_ERROR );
  }
}


/**
 * CFPropertyList
 * {@link http://developer.apple.com/documentation/Darwin/Reference/ManPages/man5/plist.5.html Property Lists}
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 * @version $Id$
 */

/**
 * Exception for errors with the PList format
 * @author Rodney Rehm <rodney.rehm@medialize.de>
 * @author Christian Kruse <cjk@wwwtech.de>
 * @package plist
 */
class PListException extends \Exception {

}

?>