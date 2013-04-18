<?php
return array (
  'apache_child_terminate' => 
  array (
    'name' => 'apache_child_terminate',
    'title' => '在本次请求结束后终止 apache 子进程',
    'ret' => 'bool',
    'prot' => 'bool apache_child_terminate()',
  ),
  'apache_lookup_uri' => 
  array (
    'name' => 'apache_lookup_uri',
    'title' => '对指定的 URI 执行部分请求并返回所有有关信息',
    'ret' => 'object',
    'prot' => 'object apache_lookup_uri(string $filename)',
  ),
  'apache_note' => 
  array (
    'name' => 'apache_note',
    'title' => '取得或设置 apache 请求记录',
    'ret' => 'string',
    'prot' => 'string apache_note(string $note_name, string $note_value = "")',
  ),
  'apc_add' => 
  array (
    'name' => 'apc_add',
    'title' => '缓存一个变量到数据存储',
    'ret' => 'bool',
    'prot' => 'bool apc_add(string $key, mixed $var, int $ttl = 0)',
  ),
  'apc_clear_cache' => 
  array (
    'name' => 'apc_clear_cache',
    'title' => '清除APC缓存',
    'ret' => 'bool',
    'prot' => 'bool apc_clear_cache(string $cache_type)',
  ),
  'apc_delete' => 
  array (
    'name' => 'apc_delete',
    'title' => '从用户缓存中删除某个变量',
    'ret' => 'mixed',
    'prot' => 'mixed apc_delete(string $key)',
  ),
  'apc_exists' => 
  array (
    'name' => 'apc_exists',
    'title' => '检查APC中是否存在某个或者某些key',
    'ret' => 'mixed',
    'prot' => 'mixed apc_exists(mixed $keys)',
  ),
  'apc_fetch' => 
  array (
    'name' => 'apc_fetch',
    'title' => '从缓存中取出存储的变量',
    'ret' => 'mixed',
    'prot' => 'mixed apc_fetch(mixed $key, boolsuccess)',
  ),
  'apc_inc' => 
  array (
    'name' => 'apc_inc',
    'title' => '递增一个储存的数字',
    'ret' => 'int',
    'prot' => 'int apc_inc(string $key, int $step = 1, boolsuccess)',
  ),
  'apc_store' => 
  array (
    'name' => 'apc_store',
    'title' => 'Cache a variable in the data store',
    'ret' => 'bool',
    'prot' => 'bool apc_store(string $key, mixed $var, int $ttl = 0)',
  ),
  'array_change_key_case' => 
  array (
    'name' => 'array_change_key_case',
    'title' => '返回字符串键名全为小写或大写的数组',
    'ret' => 'array',
    'prot' => 'array array_change_key_case(array $input, int $case = CASE_LOWER)',
  ),
  'array_chunk' => 
  array (
    'name' => 'array_chunk',
    'title' => '将一个数组分割成多个',
    'ret' => 'array',
    'prot' => 'array array_chunk(array $input, int $size, bool $preserve_keys = false)',
  ),
  'array_combine' => 
  array (
    'name' => 'array_combine',
    'title' => '创建一个数组，用一个数组的值作为其键名，另一个数组的值作为其值',
    'ret' => 'array',
    'prot' => 'array array_combine(array $keys, array $values)',
  ),
  'array_count_values' => 
  array (
    'name' => 'array_count_values',
    'title' => '统计数组中所有的值出现的次数',
    'ret' => 'array',
    'prot' => 'array array_count_values(array $input)',
  ),
  'array_diff_assoc' => 
  array (
    'name' => 'array_diff_assoc',
    'title' => '带索引检查计算数组的差集',
    'ret' => 'array',
    'prot' => 'array array_diff_assoc(array $array1, array $array2, array $...)',
  ),
  'array_diff_key' => 
  array (
    'name' => 'array_diff_key',
    'title' => '使用键名比较计算数组的差集',
    'ret' => 'array',
    'prot' => 'array array_diff_key(array $array1, array $array2, array $...)',
  ),
  'array_diff_uassoc' => 
  array (
    'name' => 'array_diff_uassoc',
    'title' => '用用户提供的回调函数做索引检查来计算数组的差集',
    'ret' => 'array',
    'prot' => 'array array_diff_uassoc(array $array1, array $array2, array $..., callable $key_compare_func)',
  ),
  'array_diff_ukey' => 
  array (
    'name' => 'array_diff_ukey',
    'title' => '用回调函数对键名比较计算数组的差集',
    'ret' => 'array',
    'prot' => 'array array_diff_ukey(array $array1, array $array2, array $ ..., callable $key_compare_func)',
  ),
  'array_diff' => 
  array (
    'name' => 'array_diff',
    'title' => '计算数组的差集',
    'ret' => 'array',
    'prot' => 'array array_diff(array $array1, array $array2, array $...)',
  ),
  'array_fill_keys' => 
  array (
    'name' => 'array_fill_keys',
    'title' => '使用指定的键和值填充数组',
    'ret' => 'array',
    'prot' => 'array array_fill_keys(array $keys, mixed $value)',
  ),
  'array_fill' => 
  array (
    'name' => 'array_fill',
    'title' => '用给定的值填充数组',
    'ret' => 'array',
    'prot' => 'array array_fill(int $start_index, int $num, mixed $value)',
  ),
  'array_filter' => 
  array (
    'name' => 'array_filter',
    'title' => '用回调函数过滤数组中的单元',
    'ret' => 'array',
    'prot' => 'array array_filter(array $input, callable $callback = "")',
  ),
  'array_flip' => 
  array (
    'name' => 'array_flip',
    'title' => '交换数组中的键和值',
    'ret' => 'array',
    'prot' => 'array array_flip(array $trans)',
  ),
  'array_intersect_assoc' => 
  array (
    'name' => 'array_intersect_assoc',
    'title' => '带索引检查计算数组的交集',
    'ret' => 'array',
    'prot' => 'array array_intersect_assoc(array $array1, array $array2, array $ ...)',
  ),
  'array_intersect_key' => 
  array (
    'name' => 'array_intersect_key',
    'title' => '使用键名比较计算数组的交集',
    'ret' => 'array',
    'prot' => 'array array_intersect_key(array $array1, array $array2, array $ ...)',
  ),
  'array_intersect_uassoc' => 
  array (
    'name' => 'array_intersect_uassoc',
    'title' => '带索引检查计算数组的交集，用回调函数比较索引',
    'ret' => 'array',
    'prot' => 'array array_intersect_uassoc(array $array1, array $array2, array $ ..., callable $key_compare_func)',
  ),
  'array_intersect_ukey' => 
  array (
    'name' => 'array_intersect_ukey',
    'title' => '用回调函数比较键名来计算数组的交集',
    'ret' => 'array',
    'prot' => 'array array_intersect_ukey(array $array1, array $array2, array $..., callable $key_compare_func)',
  ),
  'array_intersect' => 
  array (
    'name' => 'array_intersect',
    'title' => '计算数组的交集',
    'ret' => 'array',
    'prot' => 'array array_intersect(array $array1, array $array2, array $ ...)',
  ),
  'array_key_exists' => 
  array (
    'name' => 'array_key_exists',
    'title' => '检查给定的键名或索引是否存在于数组中',
    'ret' => 'bool',
    'prot' => 'bool array_key_exists(mixed $key, array $search)',
  ),
  'array_keys' => 
  array (
    'name' => 'array_keys',
    'title' => '返回数组中所有的键名',
    'ret' => 'array',
    'prot' => 'array array_keys(array $input, mixed $search_value = &null;, bool $strict = false)',
  ),
  'array_map' => 
  array (
    'name' => 'array_map',
    'title' => '将回调函数作用到给定数组的单元上',
    'ret' => 'array',
    'prot' => 'array array_map(callable $callback, array $arr1, array $...)',
  ),
  'array_merge_recursive' => 
  array (
    'name' => 'array_merge_recursive',
    'title' => '递归地合并一个或多个数组',
    'ret' => 'array',
    'prot' => 'array array_merge_recursive(array $array1, array $...)',
  ),
  'array_merge' => 
  array (
    'name' => 'array_merge',
    'title' => '合并一个或多个数组',
    'ret' => 'array',
    'prot' => 'array array_merge(array $array1, array $...)',
  ),
  'array_multisort' => 
  array (
    'name' => 'array_multisort',
    'title' => '对多个数组或多维数组进行排序',
    'ret' => 'bool',
    'prot' => 'bool array_multisort(arrayarr, mixed $arg = SORT_ASC, mixed $arg = SORT_REGULAR, mixed $...)',
  ),
  'array_pad' => 
  array (
    'name' => 'array_pad',
    'title' => '用值将数组填补到指定长度',
    'ret' => 'array',
    'prot' => 'array array_pad(array $input, int $pad_size, mixed $pad_value)',
  ),
  'array_pop' => 
  array (
    'name' => 'array_pop',
    'title' => '将数组最后一个单元弹出（出栈）',
    'ret' => 'mixed',
    'prot' => 'mixed array_pop(arrayarray)',
  ),
  'array_product' => 
  array (
    'name' => 'array_product',
    'title' => '计算数组中所有值的乘积',
    'ret' => 'number',
    'prot' => 'number array_product(array $array)',
  ),
  'array_push' => 
  array (
    'name' => 'array_push',
    'title' => '将一个或多个单元压入数组的末尾（入栈）',
    'ret' => 'int',
    'prot' => 'int array_push(arrayarray, mixed $var, mixed $...)',
  ),
  'array_rand' => 
  array (
    'name' => 'array_rand',
    'title' => '从数组中随机取出一个或多个单元',
    'ret' => 'mixed',
    'prot' => 'mixed array_rand(array $input, int $num_req = 1)',
  ),
  'array_reduce' => 
  array (
    'name' => 'array_reduce',
    'title' => '用回调函数迭代地将数组简化为单一的值',
    'ret' => 'mixed',
    'prot' => 'mixed array_reduce(array $input, callable $function, mixed $initial = &null;)',
  ),
  'array_replace_recursive' => 
  array (
    'name' => 'array_replace_recursive',
    'title' => '使用传递的数组递归替换第一个数组的元素',
    'ret' => 'array',
    'prot' => 'array array_replace_recursive(array $array, array $array1, array $...)',
  ),
  'array_replace' => 
  array (
    'name' => 'array_replace',
    'title' => '使用传递的数组替换第一个数组的元素',
    'ret' => 'array',
    'prot' => 'array array_replace(array $array, array $array1, array $...)',
  ),
  'array_reverse' => 
  array (
    'name' => 'array_reverse',
    'title' => '返回一个单元顺序相反的数组',
    'ret' => 'array',
    'prot' => 'array array_reverse(array $array, bool $preserve_keys = false)',
  ),
  'array_search' => 
  array (
    'name' => 'array_search',
    'title' => '在数组中搜索给定的值，如果成功则返回相应的键名',
    'ret' => 'mixed',
    'prot' => 'mixed array_search(mixed $needle, array $haystack, bool $strict = false)',
  ),
  'array_shift' => 
  array (
    'name' => 'array_shift',
    'title' => '将数组开头的单元移出数组',
    'ret' => 'mixed',
    'prot' => 'mixed array_shift(arrayarray)',
  ),
  'array_slice' => 
  array (
    'name' => 'array_slice',
    'title' => '从数组中取出一段',
    'ret' => 'array',
    'prot' => 'array array_slice(array $array, int $offset, int $length = &null;, bool $preserve_keys = false)',
  ),
  'array_splice' => 
  array (
    'name' => 'array_splice',
    'title' => '把数组中的一部分去掉并用其它值取代',
    'ret' => 'array',
    'prot' => 'array array_splice(arrayinput, int $offset, int $length = 0, mixed $replacement)',
  ),
  'array_sum' => 
  array (
    'name' => 'array_sum',
    'title' => '计算数组中所有值的和',
    'ret' => 'number',
    'prot' => 'number array_sum(array $array)',
  ),
  'array_udiff_assoc' => 
  array (
    'name' => 'array_udiff_assoc',
    'title' => '带索引检查计算数组的差集，用回调函数比较数据',
    'ret' => 'array',
    'prot' => 'array array_udiff_assoc(array $array1, array $array2, array $ ..., callable $data_compare_func)',
  ),
  'array_udiff_uassoc' => 
  array (
    'name' => 'array_udiff_uassoc',
    'title' => '带索引检查计算数组的差集，用回调函数比较数据和索引',
    'ret' => 'array',
    'prot' => 'array array_udiff_uassoc(array $array1, array $array2, array $ ..., callable $data_compare_func, callable $key_compare_func)',
  ),
  'array_udiff' => 
  array (
    'name' => 'array_udiff',
    'title' => '用回调函数比较数据来计算数组的差集',
    'ret' => 'array',
    'prot' => 'array array_udiff(array $array1, array $array2, array $ ..., callable $data_compare_func)',
  ),
  'array_uintersect_assoc' => 
  array (
    'name' => 'array_uintersect_assoc',
    'title' => '带索引检查计算数组的交集，用回调函数比较数据',
    'ret' => 'array',
    'prot' => 'array array_uintersect_assoc(array $array1, array $array2, array $ ..., callable $data_compare_func)',
  ),
  'array_uintersect_uassoc' => 
  array (
    'name' => 'array_uintersect_uassoc',
    'title' => '带索引检查计算数组的交集，用回调函数比较数据和索引',
    'ret' => 'array',
    'prot' => 'array array_uintersect_uassoc(array $array1, array $array2, array $ ..., callable $data_compare_func, callable $key_compare_func)',
  ),
  'array_uintersect' => 
  array (
    'name' => 'array_uintersect',
    'title' => '计算数组的交集，用回调函数比较数据',
    'ret' => 'array',
    'prot' => 'array array_uintersect(array $array1, array $array2, array $ ..., callable $data_compare_func)',
  ),
  'array_unique' => 
  array (
    'name' => 'array_unique',
    'title' => '移除数组中重复的值',
    'ret' => 'array',
    'prot' => 'array array_unique(array $array, int $sort_flags = SORT_STRING)',
  ),
  'array_unshift' => 
  array (
    'name' => 'array_unshift',
    'title' => '在数组开头插入一个或多个单元',
    'ret' => 'int',
    'prot' => 'int array_unshift(arrayarray, mixed $var, mixed $...)',
  ),
  'array_values' => 
  array (
    'name' => 'array_values',
    'title' => '返回数组中所有的值',
    'ret' => 'array',
    'prot' => 'array array_values(array $input)',
  ),
  'array_walk_recursive' => 
  array (
    'name' => 'array_walk_recursive',
    'title' => '对数组中的每个成员递归地应用用户函数',
    'ret' => 'bool',
    'prot' => 'bool array_walk_recursive(arrayinput, callable $funcname, mixed $userdata = &null;)',
  ),
  'array_walk' => 
  array (
    'name' => 'array_walk',
    'title' => '对数组中的每个成员应用用户函数',
    'ret' => 'bool',
    'prot' => 'bool array_walk(arrayarray, callable $funcname, mixed $userdata = &null;)',
  ),
  'array' => 
  array (
    'name' => 'array',
    'title' => '新建一个数组',
    'ret' => 'array',
    'prot' => 'array array(mixed $...)',
  ),
  'arsort' => 
  array (
    'name' => 'arsort',
    'title' => '对数组进行逆向排序并保持索引关系',
    'ret' => 'bool',
    'prot' => 'bool arsort(arrayarray, int $sort_flags = SORT_REGULAR)',
  ),
  'asort' => 
  array (
    'name' => 'asort',
    'title' => '对数组进行排序并保持索引关系',
    'ret' => 'bool',
    'prot' => 'bool asort(arrayarray, int $sort_flags = SORT_REGULAR)',
  ),
  'compact' => 
  array (
    'name' => 'compact',
    'title' => '建立一个数组，包括变量名和它们的值',
    'ret' => 'array',
    'prot' => 'array compact(mixed $varname, mixed $...)',
  ),
  'count' => 
  array (
    'name' => 'count',
    'title' => '计算数组中的单元数目或对象中的属性个数',
    'ret' => 'int',
    'prot' => 'int count(mixed $var, int $mode = COUNT_NORMAL)',
  ),
  'current' => 
  array (
    'name' => 'current',
    'title' => '返回数组中的当前单元',
    'ret' => 'mixed',
    'prot' => 'mixed current(arrayarray)',
  ),
  'each' => 
  array (
    'name' => 'each',
    'title' => '返回数组中当前的键／值对并将数组指针向前移动一步',
    'ret' => 'array',
    'prot' => 'array each(arrayarray)',
  ),
  'end' => 
  array (
    'name' => 'end',
    'title' => '将数组的内部指针指向最后一个单元',
    'ret' => 'mixed',
    'prot' => 'mixed end(arrayarray)',
  ),
  'extract' => 
  array (
    'name' => 'extract',
    'title' => '从数组中将变量导入到当前的符号表',
    'ret' => 'int',
    'prot' => 'int extract(arrayvar_array, int $extract_type = EXTR_OVERWRITE, string $prefix = &null;)',
  ),
  'in_array' => 
  array (
    'name' => 'in_array',
    'title' => '检查数组中是否存在某个值',
    'ret' => 'bool',
    'prot' => 'bool in_array(mixed $needle, array $haystack, bool $strict = &false;)',
  ),
  'key' => 
  array (
    'name' => 'key',
    'title' => '从关联数组中取得键名',
    'ret' => 'mixed',
    'prot' => 'mixed key(arrayarray)',
  ),
  'krsort' => 
  array (
    'name' => 'krsort',
    'title' => '对数组按照键名逆向排序',
    'ret' => 'bool',
    'prot' => 'bool krsort(arrayarray, int $sort_flags = SORT_REGULAR)',
  ),
  'ksort' => 
  array (
    'name' => 'ksort',
    'title' => '对数组按照键名排序',
    'ret' => 'bool',
    'prot' => 'bool ksort(arrayarray, int $sort_flags = SORT_REGULAR)',
  ),
  'list' => 
  array (
    'name' => 'list',
    'title' => '把数组中的值赋给一些变量',
    'ret' => 'array',
    'prot' => 'array list(mixed $varname, mixed $...)',
  ),
  'natcasesort' => 
  array (
    'name' => 'natcasesort',
    'title' => '用“自然排序”算法对数组进行不区分大小写字母的排序',
    'ret' => 'bool',
    'prot' => 'bool natcasesort(arrayarray)',
  ),
  'natsort' => 
  array (
    'name' => 'natsort',
    'title' => '用“自然排序”算法对数组排序',
    'ret' => 'bool',
    'prot' => 'bool natsort(arrayarray)',
  ),
  'next' => 
  array (
    'name' => 'next',
    'title' => '将数组中的内部指针向前移动一位',
    'ret' => 'mixed',
    'prot' => 'mixed next(arrayarray)',
  ),
  'pos' => 
  array (
    'name' => 'pos',
    'title' => 'current 的&Alias;',
    'ret' => 'mixed',
    'prot' => 'mixed pos(arrayarray)',
  ),
  'prev' => 
  array (
    'name' => 'prev',
    'title' => '将数组的内部指针倒回一位',
    'ret' => 'mixed',
    'prot' => 'mixed prev(arrayarray)',
  ),
  'range' => 
  array (
    'name' => 'range',
    'title' => '建立一个包含指定范围单元的数组',
    'ret' => 'array',
    'prot' => 'array range(mixed $start, mixed $limit, number $step = 1)',
  ),
  'reset' => 
  array (
    'name' => 'reset',
    'title' => '将数组的内部指针指向第一个单元',
    'ret' => 'mixed',
    'prot' => 'mixed reset(arrayarray)',
  ),
  'rsort' => 
  array (
    'name' => 'rsort',
    'title' => '对数组逆向排序',
    'ret' => 'bool',
    'prot' => 'bool rsort(arrayarray, int $sort_flags = SORT_REGULAR)',
  ),
  'shuffle' => 
  array (
    'name' => 'shuffle',
    'title' => '将数组打乱',
    'ret' => 'bool',
    'prot' => 'bool shuffle(arrayarray)',
  ),
  'sizeof' => 
  array (
    'name' => 'sizeof',
    'title' => 'count 的&Alias;',
    'ret' => 'bool',
    'prot' => 'bool sizeof(arrayarray)',
  ),
  'sort' => 
  array (
    'name' => 'sort',
    'title' => '对数组排序',
    'ret' => 'bool',
    'prot' => 'bool sort(arrayarray, int $sort_flags = SORT_REGULAR)',
  ),
  'uasort' => 
  array (
    'name' => 'uasort',
    'title' => '使用用户自定义的比较函数对数组中的值进行排序并保持索引关联',
    'ret' => 'bool',
    'prot' => 'bool uasort(arrayarray, callable $cmp_function)',
  ),
  'uksort' => 
  array (
    'name' => 'uksort',
    'title' => '使用用户自定义的比较函数对数组中的键名进行排序',
    'ret' => 'bool',
    'prot' => 'bool uksort(arrayarray, callable $cmp_function)',
  ),
  'usort' => 
  array (
    'name' => 'usort',
    'title' => '使用用户自定义的比较函数对数组中的值进行排序',
    'ret' => 'bool',
    'prot' => 'bool usort(arrayarray, callable $cmp_function)',
  ),
  'bcompiler_load_exe' => 
  array (
    'name' => 'bcompiler_load_exe',
    'title' => '从一个 bcompiler exe 文件中读取并创建类',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_load_exe(string $filename)',
  ),
  'bcompiler_load' => 
  array (
    'name' => 'bcompiler_load',
    'title' => '从一个 bz 压缩过的文件中读取并创建类',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_load(string $filename)',
  ),
  'bcompiler_parse_class' => 
  array (
    'name' => 'bcompiler_parse_class',
    'title' => '读取一个类的字节码并回调一个用户的函数',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_parse_class(string $class, string $callback)',
  ),
  'bcompiler_read' => 
  array (
    'name' => 'bcompiler_read',
    'title' => '从一个文件句柄中读取并创建类',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_read(resource $filehandle)',
  ),
  'bcompiler_write_class' => 
  array (
    'name' => 'bcompiler_write_class',
    'title' => '写入定义过的类的字节码',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_class(resource $filehandle, string $className, string $extends)',
  ),
  'bcompiler_write_constant' => 
  array (
    'name' => 'bcompiler_write_constant',
    'title' => '写入定义过的常量的字节码',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_constant(resource $filehandle, string $constantName)',
  ),
  'bcompiler_write_exe_footer' => 
  array (
    'name' => 'bcompiler_write_exe_footer',
    'title' => '写入开始位置以及 exe 类型文件的结尾信号',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_exe_footer(resource $filehandle, int $startpos)',
  ),
  'bcompiler_write_file' => 
  array (
    'name' => 'bcompiler_write_file',
    'title' => '写入 PHP 源码文件的字节码',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_file(resource $filehandle, string $filename)',
  ),
  'bcompiler_write_footer' => 
  array (
    'name' => 'bcompiler_write_footer',
    'title' => '写入单个字符 \\x00 用于标识编译数据的结尾',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_footer(resource $filehandle)',
  ),
  'bcompiler_write_function' => 
  array (
    'name' => 'bcompiler_write_function',
    'title' => '以字节码写入定义过的函数',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_function(resource $filehandle, string $functionName)',
  ),
  'bcompiler_write_functions_from_file' => 
  array (
    'name' => 'bcompiler_write_functions_from_file',
    'title' => '以字节码写入一个文件中定义过的所以函数',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_functions_from_file(resource $filehandle, string $fileName)',
  ),
  'bcompiler_write_header' => 
  array (
    'name' => 'bcompiler_write_header',
    'title' => '写入 bcompiler 头',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_header(resource $filehandle, string $write_ver)',
  ),
  'bcompiler_write_included_filename' => 
  array (
    'name' => 'bcompiler_write_included_filename',
    'title' => '写入一个包含的文件的字节码',
    'ret' => 'bool',
    'prot' => 'bool bcompiler_write_included_filename(resource $filehandle, string $filename)',
  ),
  'bzclose' => 
  array (
    'name' => 'bzclose',
    'title' => '关闭一个 bzip2 文件',
    'ret' => 'int',
    'prot' => 'int bzclose(resource $bz)',
  ),
  'bzcompress' => 
  array (
    'name' => 'bzcompress',
    'title' => '把一个字符串压缩成 bzip2 编码数据',
    'ret' => 'mixed',
    'prot' => 'mixed bzcompress(string $source, int $blocksize = 4, int $workfactor = 0)',
  ),
  'bzdecompress' => 
  array (
    'name' => 'bzdecompress',
    'title' => '解压经 bzip2 编码过的数据',
    'ret' => 'mixed',
    'prot' => 'mixed bzdecompress(string $source, int $small = 0)',
  ),
  'bzerrno' => 
  array (
    'name' => 'bzerrno',
    'title' => '返回一个 bzip2 错误码',
    'ret' => 'int',
    'prot' => 'int bzerrno(resource $bz)',
  ),
  'bzerror' => 
  array (
    'name' => 'bzerror',
    'title' => '返回包含 bzip2 错误号和错误字符串的一个 array',
    'ret' => 'array',
    'prot' => 'array bzerror(resource $bz)',
  ),
  'bzerrstr' => 
  array (
    'name' => 'bzerrstr',
    'title' => '返回一个 bzip2 的错误字符串',
    'ret' => 'string',
    'prot' => 'string bzerrstr(resource $bz)',
  ),
  'bzflush' => 
  array (
    'name' => 'bzflush',
    'title' => '强制写入所有写缓冲区的数据',
    'ret' => 'int',
    'prot' => 'int bzflush(resource $bz)',
  ),
  'bzopen' => 
  array (
    'name' => 'bzopen',
    'title' => '打开一个经 bzip2 压缩过的文件',
    'ret' => 'resource',
    'prot' => 'resource bzopen(string $filename, string $mode)',
  ),
  'bzread' => 
  array (
    'name' => 'bzread',
    'title' => 'bzip2 文件二进制安全地读取',
    'ret' => 'string',
    'prot' => 'string bzread(resource $bz, int $length = 1024)',
  ),
  'bzwrite' => 
  array (
    'name' => 'bzwrite',
    'title' => '二进制安全地写入 bzip2 文件',
    'ret' => 'int',
    'prot' => 'int bzwrite(resource $bz, string $data, int $length)',
  ),
  'cal_days_in_month' => 
  array (
    'name' => 'cal_days_in_month',
    'title' => '返回某个历法中某年中某月的天数',
    'ret' => 'int',
    'prot' => 'int cal_days_in_month(int $calendar, int $month, int $year)',
  ),
  'cal_from_jd' => 
  array (
    'name' => 'cal_from_jd',
    'title' => '转换Julian Day计数到一个支持的历法。',
    'ret' => 'array',
    'prot' => 'array cal_from_jd(int $jd, int $calendar)',
  ),
  'cal_info' => 
  array (
    'name' => 'cal_info',
    'title' => '返回选定历法的信息',
    'ret' => 'array',
    'prot' => 'array cal_info(int $calendar = -1)',
  ),
  'cal_to_jd' => 
  array (
    'name' => 'cal_to_jd',
    'title' => '从一个支持的历法转变为Julian Day计数。',
    'ret' => 'int',
    'prot' => 'int cal_to_jd(int $calendar, int $month, int $day, int $year)',
  ),
  'easter_date' => 
  array (
    'name' => 'easter_date',
    'title' => '得到指定年份的复活节午夜时的Unix时间戳。',
    'ret' => 'int',
    'prot' => 'int easter_date(int $year)',
  ),
  'easter_days' => 
  array (
    'name' => 'easter_days',
    'title' => '得到指定年份的3月21日到复活节之间的天数',
    'ret' => 'int',
    'prot' => 'int easter_days(int $year, int $method = CAL_EASTER_DEFAULT)',
  ),
  'FrenchToJD' => 
  array (
    'name' => 'FrenchToJD',
    'title' => '从一个French Republican历法的日期得到Julian Day计数。',
    'ret' => 'int',
    'prot' => 'int FrenchToJD(int $month, int $day, int $year)',
  ),
  'GregorianToJD' => 
  array (
    'name' => 'GregorianToJD',
    'title' => '转变一个Gregorian历法日期到Julian Day计数',
    'ret' => 'int',
    'prot' => 'int GregorianToJD(int $month, int $day, int $year)',
  ),
  'JDDayOfWeek' => 
  array (
    'name' => 'JDDayOfWeek',
    'title' => '返回星期的日期',
    'ret' => 'mixed',
    'prot' => 'mixed JDDayOfWeek(int $julianday, int $mode = CAL_DOW_DAYNO)',
  ),
  'JDMonthName' => 
  array (
    'name' => 'JDMonthName',
    'title' => '返回月份的名称',
    'ret' => 'string',
    'prot' => 'string JDMonthName(int $julianday, int $mode)',
  ),
  'JDToFrench' => 
  array (
    'name' => 'JDToFrench',
    'title' => '转变一个Julian Day计数到French Republican历法的日期',
    'ret' => 'string',
    'prot' => 'string JDToFrench(int $juliandaycount)',
  ),
  'JDToGregorian' => 
  array (
    'name' => 'JDToGregorian',
    'title' => '转变一个Julian Day计数为Gregorian历法日期',
    'ret' => 'string',
    'prot' => 'string JDToGregorian(int $julianday)',
  ),
  'jdtojewish' => 
  array (
    'name' => 'jdtojewish',
    'title' => '转换一个julian天数为Jewish历法的日期',
    'ret' => 'string',
    'prot' => 'string jdtojewish(int $juliandaycount, bool $hebrew = false, int $fl = 0)',
  ),
  'JDToJulian' => 
  array (
    'name' => 'JDToJulian',
    'title' => '转变一个Julian Day计数到Julian历法的日期',
    'ret' => 'string',
    'prot' => 'string JDToJulian(int $julianday)',
  ),
  'jdtounix' => 
  array (
    'name' => 'jdtounix',
    'title' => '转变Julian Day计数为一个Unix时间戳',
    'ret' => 'int',
    'prot' => 'int jdtounix(int $jday)',
  ),
  'JewishToJD' => 
  array (
    'name' => 'JewishToJD',
    'title' => '转变一个Jewish历法的日期为一个Julian Day计数',
    'ret' => 'int',
    'prot' => 'int JewishToJD(int $month, int $day, int $year)',
  ),
  'JulianToJD' => 
  array (
    'name' => 'JulianToJD',
    'title' => '转变一个Julian历法的日期为Julian Day计数',
    'ret' => 'int',
    'prot' => 'int JulianToJD(int $month, int $day, int $year)',
  ),
  'unixtojd' => 
  array (
    'name' => 'unixtojd',
    'title' => '转变Unix时间戳为Julian Day计数',
    'ret' => 'int',
    'prot' => 'int unixtojd(int $timestamp = time())',
  ),
  '__autoload' => 
  array (
    'name' => '__autoload',
    'title' => '尝试加载未定义的类',
    'ret' => 'void',
    'prot' => 'void __autoload(string $class)',
  ),
  'call_user_method_array' => 
  array (
    'name' => 'call_user_method_array',
    'title' => '调用一个用户方法，同时传递参数数组（已废弃）',
    'ret' => 'mixed',
    'prot' => 'mixed call_user_method_array(string $method_name, objectobj, array $paramarr)',
  ),
  'call_user_method' => 
  array (
    'name' => 'call_user_method',
    'title' => '对特定对象调用用户方法（已废弃）',
    'ret' => 'mixed',
    'prot' => 'mixed call_user_method(string $method_name, objectobj, mixed $parameter, mixed $...)',
  ),
  'class_alias' => 
  array (
    'name' => 'class_alias',
    'title' => '为一个类创建别名',
    'ret' => 'bool',
    'prot' => 'bool class_alias(string $original, string $alias, bool $autoload = &true;)',
  ),
  'class_exists' => 
  array (
    'name' => 'class_exists',
    'title' => '检查类是否已定义',
    'ret' => 'bool',
    'prot' => 'bool class_exists(string $class_name, bool $autoload = true)',
  ),
  'get_called_class' => 
  array (
    'name' => 'get_called_class',
    'title' => '后期静态绑定（"Late Static Binding"）类的名称',
    'ret' => 'string',
    'prot' => 'string get_called_class()',
  ),
  'get_class_methods' => 
  array (
    'name' => 'get_class_methods',
    'title' => '返回由类的方法名组成的数组',
    'ret' => 'array',
    'prot' => 'array get_class_methods(mixed $class_name)',
  ),
  'get_class_vars' => 
  array (
    'name' => 'get_class_vars',
    'title' => '返回由类的默认属性组成的数组',
    'ret' => 'array',
    'prot' => 'array get_class_vars(string $class_name)',
  ),
  'get_class' => 
  array (
    'name' => 'get_class',
    'title' => '返回对象的类名',
    'ret' => 'string',
    'prot' => 'string get_class(object $obj)',
  ),
  'get_declared_classes' => 
  array (
    'name' => 'get_declared_classes',
    'title' => '返回由已定义类的名字所组成的数组',
    'ret' => 'array',
    'prot' => 'array get_declared_classes()',
  ),
  'get_declared_interfaces' => 
  array (
    'name' => 'get_declared_interfaces',
    'title' => '返回一个数组包含所有已声明的接口',
    'ret' => 'array',
    'prot' => 'array get_declared_interfaces()',
  ),
  'get_declared_traits' => 
  array (
    'name' => 'get_declared_traits',
    'title' => '返回所有已定义的 traits 的数组',
    'ret' => 'array',
    'prot' => 'array get_declared_traits()',
  ),
  'get_object_vars' => 
  array (
    'name' => 'get_object_vars',
    'title' => '返回由对象属性组成的关联数组',
    'ret' => 'array',
    'prot' => 'array get_object_vars(object $obj)',
  ),
  'get_parent_class' => 
  array (
    'name' => 'get_parent_class',
    'title' => '返回对象或类的父类名',
    'ret' => 'string',
    'prot' => 'string get_parent_class(mixed $obj)',
  ),
  'interface_exists' => 
  array (
    'name' => 'interface_exists',
    'title' => '检查接口是否已被定义',
    'ret' => 'bool',
    'prot' => 'bool interface_exists(string $interface_name, bool $autoload = true)',
  ),
  'is_a' => 
  array (
    'name' => 'is_a',
    'title' => '如果对象属于该类或该类是此对象的父类则返回 &true;',
    'ret' => 'bool',
    'prot' => 'bool is_a(object $object, string $class_name)',
  ),
  'is_subclass_of' => 
  array (
    'name' => 'is_subclass_of',
    'title' => '如果此对象是该类的子类，则返回 &true;',
    'ret' => 'bool',
    'prot' => 'bool is_subclass_of(object $object, string $class_name)',
  ),
  'method_exists' => 
  array (
    'name' => 'method_exists',
    'title' => '检查类的方法是否存在',
    'ret' => 'bool',
    'prot' => 'bool method_exists(mixed $object, string $method_name)',
  ),
  'property_exists' => 
  array (
    'name' => 'property_exists',
    'title' => '检查对象或类是否具有该属性',
    'ret' => 'bool',
    'prot' => 'bool property_exists(mixed $class, string $property)',
  ),
  'trait_exists' => 
  array (
    'name' => 'trait_exists',
    'title' => '检查指定的 trait 是否存在',
    'ret' => 'bool',
    'prot' => 'bool trait_exists(string $traitname, bool $autoload)',
  ),
  'com_addref' => 
  array (
    'name' => 'com_addref',
    'title' => '增加组件引用计数。[被废弃]',
    'ret' => 'void',
    'prot' => 'void com_addref()',
  ),
  'com_get' => 
  array (
    'name' => 'com_get',
    'title' => '获取 COM 组件的属性值 [被废弃]',
    'ret' => 'void',
    'prot' => 'void com_get()',
  ),
  'com_invoke' => 
  array (
    'name' => 'com_invoke',
    'title' => '调用 COM 组件的方法。',
    'ret' => 'mixed',
    'prot' => 'mixed com_invoke(resource $com_object, string $function_name, mixed $
      function parameters, ...)',
  ),
  'com_isenum' => 
  array (
    'name' => 'com_isenum',
    'title' => '获取一个 IEnumVariant',
    'ret' => 'bool',
    'prot' => 'bool com_isenum(variant $com_module)',
  ),
  'com_load_typelib' => 
  array (
    'name' => 'com_load_typelib',
    'title' => '装载一个 Typelib',
    'ret' => 'bool',
    'prot' => 'bool com_load_typelib(string $typelib_name, bool $case_insensitive = true)',
  ),
  'com_load' => 
  array (
    'name' => 'com_load',
    'title' => '创建新的 COM 组件的引用',
    'ret' => 'string',
    'prot' => 'string com_load(string $module_name, string $
      server_name
      , int $
      codepage)',
  ),
  'com_propget' => 
  array (
    'name' => 'com_propget',
    'title' => 'com_get 的别名',
    'ret' => 'string',
    'prot' => 'string com_propget(string $module_name, string $
      server_name
      , int $
      codepage)',
  ),
  'com_propput' => 
  array (
    'name' => 'com_propput',
    'title' => 'com_set 的别名',
    'ret' => 'string',
    'prot' => 'string com_propput(string $module_name, string $
      server_name
      , int $
      codepage)',
  ),
  'com_propset' => 
  array (
    'name' => 'com_propset',
    'title' => 'com_set 的别名',
    'ret' => 'string',
    'prot' => 'string com_propset(string $module_name, string $
      server_name
      , int $
      codepage)',
  ),
  'com_release' => 
  array (
    'name' => 'com_release',
    'title' => '减少组件引用计数。[被废弃]',
    'ret' => 'void',
    'prot' => 'void com_release()',
  ),
  'com_set' => 
  array (
    'name' => 'com_set',
    'title' => '给 COM 组件的属性赋值',
    'ret' => 'void',
    'prot' => 'void com_set()',
  ),
  'curl_close' => 
  array (
    'name' => 'curl_close',
    'title' => '关闭一个cURL会话',
    'ret' => 'void',
    'prot' => 'void curl_close(resource $ch)',
  ),
  'curl_copy_handle' => 
  array (
    'name' => 'curl_copy_handle',
    'title' => '复制一个cURL句柄和它的所有选项',
    'ret' => 'resource',
    'prot' => 'resource curl_copy_handle(resource $ch)',
  ),
  'curl_errno' => 
  array (
    'name' => 'curl_errno',
    'title' => '返回最后一次的错误号',
    'ret' => 'int',
    'prot' => 'int curl_errno(resource $ch)',
  ),
  'curl_error' => 
  array (
    'name' => 'curl_error',
    'title' => '返回一个保护当前会话最近一次错误的字符串',
    'ret' => 'string',
    'prot' => 'string curl_error(resource $ch)',
  ),
  'curl_exec' => 
  array (
    'name' => 'curl_exec',
    'title' => '执行一个cURL会话',
    'ret' => 'mixed',
    'prot' => 'mixed curl_exec(resource $ch)',
  ),
  'curl_getinfo' => 
  array (
    'name' => 'curl_getinfo',
    'title' => '获取一个cURL连接资源句柄的信息',
    'ret' => 'mixed',
    'prot' => 'mixed curl_getinfo(resource $ch, int $opt = 0)',
  ),
  'curl_init' => 
  array (
    'name' => 'curl_init',
    'title' => '初始化一个cURL会话',
    'ret' => 'resource',
    'prot' => 'resource curl_init(string $url = &null;)',
  ),
  'curl_multi_add_handle' => 
  array (
    'name' => 'curl_multi_add_handle',
    'title' => '向curl批处理会话中添加单独的curl句柄',
    'ret' => 'int',
    'prot' => 'int curl_multi_add_handle(resource $mh, resource $ch)',
  ),
  'curl_multi_close' => 
  array (
    'name' => 'curl_multi_close',
    'title' => '关闭一组cURL句柄',
    'ret' => 'void',
    'prot' => 'void curl_multi_close(resource $mh)',
  ),
  'curl_multi_exec' => 
  array (
    'name' => 'curl_multi_exec',
    'title' => '运行当前 cURL 句柄的子连接',
    'ret' => 'int',
    'prot' => 'int curl_multi_exec(resource $mh, intstill_running)',
  ),
  'curl_multi_getcontent' => 
  array (
    'name' => 'curl_multi_getcontent',
    'title' => '如果设置了CURLOPT_RETURNTRANSFER，则返回获取的输出的文本流',
    'ret' => 'string',
    'prot' => 'string curl_multi_getcontent(resource $ch)',
  ),
  'curl_multi_info_read' => 
  array (
    'name' => 'curl_multi_info_read',
    'title' => '获取当前解析的cURL的相关传输信息',
    'ret' => 'array',
    'prot' => 'array curl_multi_info_read(resource $mh, intmsgs_in_queue = &null;)',
  ),
  'curl_multi_init' => 
  array (
    'name' => 'curl_multi_init',
    'title' => '返回一个新cURL批处理句柄',
    'ret' => 'resource',
    'prot' => 'resource curl_multi_init()',
  ),
  'curl_multi_remove_handle' => 
  array (
    'name' => 'curl_multi_remove_handle',
    'title' => '移除curl批处理句柄资源中的某个句柄资源',
    'ret' => 'int',
    'prot' => 'int curl_multi_remove_handle(resource $mh, resource $ch)',
  ),
  'curl_multi_select' => 
  array (
    'name' => 'curl_multi_select',
    'title' => '等待所有cURL批处理中的活动连接',
    'ret' => 'int',
    'prot' => 'int curl_multi_select(resource $mh, float $timeout = 1.0)',
  ),
  'curl_setopt_array' => 
  array (
    'name' => 'curl_setopt_array',
    'title' => '为cURL传输会话批量设置选项',
    'ret' => 'bool',
    'prot' => 'bool curl_setopt_array(resource $ch, array $options)',
  ),
  'curl_setopt' => 
  array (
    'name' => 'curl_setopt',
    'title' => '设置一个cURL传输选项',
    'ret' => 'bool',
    'prot' => 'bool curl_setopt(resource $ch, int $option, mixed $value)',
  ),
  'curl_version' => 
  array (
    'name' => 'curl_version',
    'title' => '获取cURL版本信息',
    'ret' => 'array',
    'prot' => 'array curl_version(int $age = CURLVERSION_NOW)',
  ),
  'checkdate' => 
  array (
    'name' => 'checkdate',
    'title' => '验证一个格里高里日期',
    'ret' => 'bool',
    'prot' => 'bool checkdate(int $month, int $day, int $year)',
  ),
  'date_default_timezone_get' => 
  array (
    'name' => 'date_default_timezone_get',
    'title' => '取得一个脚本中所有日期时间函数所使用的默认时区',
    'ret' => 'string',
    'prot' => 'string date_default_timezone_get()',
  ),
  'date_default_timezone_set' => 
  array (
    'name' => 'date_default_timezone_set',
    'title' => '设定用于一个脚本中所有日期时间函数的默认时区',
    'ret' => 'bool',
    'prot' => 'bool date_default_timezone_set(string $timezone_identifier)',
  ),
  'date_sunrise' => 
  array (
    'name' => 'date_sunrise',
    'title' => '返回给定的日期与地点的日出时间',
    'ret' => 'mixed',
    'prot' => 'mixed date_sunrise(int $timestamp, int $format = SUNFUNCS_RET_STRING, float $latitude = ini_get("date.default_latitude"), float $longitude = ini_get("date.default_longitude"), float $zenith = ini_get("date.sunrise_zenith"), float $gmt_offset = 0)',
  ),
  'date_sunset' => 
  array (
    'name' => 'date_sunset',
    'title' => '返回给定的日期与地点的日落时间',
    'ret' => 'mixed',
    'prot' => 'mixed date_sunset(int $timestamp, int $format = SUNFUNCS_RET_STRING, float $latitude = ini_get("date.default_latitude"), float $longitude = ini_get("date.default_longitude"), float $zenith = ini_get("date.sunset_zenith"), float $gmt_offset = 0)',
  ),
  'date' => 
  array (
    'name' => 'date',
    'title' => '格式化一个本地时间／日期',
    'ret' => 'string',
    'prot' => 'string date(string $format, int $timestamp)',
  ),
  'getdate' => 
  array (
    'name' => 'getdate',
    'title' => '取得日期／时间信息',
    'ret' => 'array',
    'prot' => 'array getdate(int $timestamp = time())',
  ),
  'gettimeofday' => 
  array (
    'name' => 'gettimeofday',
    'title' => '取得当前时间',
    'ret' => 'mixed',
    'prot' => 'mixed gettimeofday(bool $return_float = false)',
  ),
  'gmdate' => 
  array (
    'name' => 'gmdate',
    'title' => '格式化一个 GMT/UTC 日期／时间',
    'ret' => 'string',
    'prot' => 'string gmdate(string $format, int $timestamp)',
  ),
  'gmmktime' => 
  array (
    'name' => 'gmmktime',
    'title' => '取得 GMT 日期的 UNIX 时间戳',
    'ret' => 'int',
    'prot' => 'int gmmktime(int $hour, int $minute, int $second, int $month, int $day, int $year, int $is_dst)',
  ),
  'gmstrftime' => 
  array (
    'name' => 'gmstrftime',
    'title' => '根据区域设置格式化 GMT/UTC 时间／日期',
    'ret' => 'string',
    'prot' => 'string gmstrftime(string $format, int $timestamp)',
  ),
  'idate' => 
  array (
    'name' => 'idate',
    'title' => '将本地时间日期格式化为整数',
    'ret' => 'int',
    'prot' => 'int idate(string $format, int $timestamp)',
  ),
  'localtime' => 
  array (
    'name' => 'localtime',
    'title' => '取得本地时间',
    'ret' => 'array',
    'prot' => 'array localtime(int $timestamp = time(), bool $is_associative = false)',
  ),
  'microtime' => 
  array (
    'name' => 'microtime',
    'title' => '返回当前 Unix 时间戳和微秒数',
    'ret' => 'mixed',
    'prot' => 'mixed microtime(bool $get_as_float)',
  ),
  'mktime' => 
  array (
    'name' => 'mktime',
    'title' => '取得一个日期的 Unix 时间戳',
    'ret' => 'int',
    'prot' => 'int mktime(int $hour = date("H"), int $minute = date("i"), int $second = date("s"), int $month = date("n"), int $day = date("j"), int $year = date("Y"), int $is_dst = -1)',
  ),
  'strftime' => 
  array (
    'name' => 'strftime',
    'title' => '根据区域设置格式化本地时间／日期',
    'ret' => 'string',
    'prot' => 'string strftime(string $format, int $timestamp = time())',
  ),
  'strptime' => 
  array (
    'name' => 'strptime',
    'title' => '解析由 strftime 生成的日期／时间',
    'ret' => 'array',
    'prot' => 'array strptime(string $date, string $format)',
  ),
  'strtotime' => 
  array (
    'name' => 'strtotime',
    'title' => '将任何英文文本的日期时间描述解析为 Unix 时间戳',
    'ret' => 'int',
    'prot' => 'int strtotime(string $time, int $now = time())',
  ),
  'time' => 
  array (
    'name' => 'time',
    'title' => '返回当前的 Unix 时间戳',
    'ret' => 'int',
    'prot' => 'int time()',
  ),
  'chdir' => 
  array (
    'name' => 'chdir',
    'title' => '改变目录',
    'ret' => 'bool',
    'prot' => 'bool chdir(string $directory)',
  ),
  'chroot' => 
  array (
    'name' => 'chroot',
    'title' => '改变根目录',
    'ret' => 'bool',
    'prot' => 'bool chroot(string $directory)',
  ),
  'closedir' => 
  array (
    'name' => 'closedir',
    'title' => '关闭目录句柄',
    'ret' => 'void',
    'prot' => 'void closedir(resource $dir_handle)',
  ),
  'getcwd' => 
  array (
    'name' => 'getcwd',
    'title' => '取得当前工作目录',
    'ret' => 'string',
    'prot' => 'string getcwd()',
  ),
  'opendir' => 
  array (
    'name' => 'opendir',
    'title' => '打开目录句柄',
    'ret' => 'resource',
    'prot' => 'resource opendir(string $path, resource $context)',
  ),
  'readdir' => 
  array (
    'name' => 'readdir',
    'title' => '从目录句柄中读取条目',
    'ret' => 'string',
    'prot' => 'string readdir(resource $dir_handle)',
  ),
  'rewinddir' => 
  array (
    'name' => 'rewinddir',
    'title' => '倒回目录句柄',
    'ret' => 'void',
    'prot' => 'void rewinddir(resource $dir_handle)',
  ),
  'scandir' => 
  array (
    'name' => 'scandir',
    'title' => '列出指定路径中的文件和目录',
    'ret' => 'array',
    'prot' => 'array scandir(string $directory, int $sorting_order, resource $context)',
  ),
  'dotnet_load' => 
  array (
    'name' => 'dotnet_load',
    'title' => '加载一个 DOTNET 模块',
    'ret' => 'int',
    'prot' => 'int dotnet_load(string $assembly_name, string $datatype_name, int $codepage)',
  ),
  'debug_backtrace' => 
  array (
    'name' => 'debug_backtrace',
    'title' => '产生一条回溯跟踪(backtrace)',
    'ret' => 'array',
    'prot' => 'array debug_backtrace(int $options = DEBUG_BACKTRACE_PROVIDE_OBJECT, int $limit = 0)',
  ),
  'debug_print_backtrace' => 
  array (
    'name' => 'debug_print_backtrace',
    'title' => '打印一条回溯。',
    'ret' => 'void',
    'prot' => 'void debug_print_backtrace(int $options = 0, int $limit = 0)',
  ),
  'error_get_last' => 
  array (
    'name' => 'error_get_last',
    'title' => '获取最后发生的错误',
    'ret' => 'array',
    'prot' => 'array error_get_last()',
  ),
  'error_log' => 
  array (
    'name' => 'error_log',
    'title' => '发送错误信息到某个地方',
    'ret' => 'bool',
    'prot' => 'bool error_log(string $message, int $message_type = 0, string $destination, string $extra_headers)',
  ),
  'error_reporting' => 
  array (
    'name' => 'error_reporting',
    'title' => '设置应该报告何种 PHP 错误',
    'ret' => 'int',
    'prot' => 'int error_reporting(int $level)',
  ),
  'restore_error_handler' => 
  array (
    'name' => 'restore_error_handler',
    'title' => '还原之前的错误处理函数',
    'ret' => 'bool',
    'prot' => 'bool restore_error_handler()',
  ),
  'restore_exception_handler' => 
  array (
    'name' => 'restore_exception_handler',
    'title' => '恢复之前定义过的异常处理函数。',
    'ret' => 'bool',
    'prot' => 'bool restore_exception_handler()',
  ),
  'set_error_handler' => 
  array (
    'name' => 'set_error_handler',
    'title' => '设置一个用户定义的错误处理函数',
    'ret' => 'mixed',
    'prot' => 'mixed set_error_handler(callable $error_handler, int $error_types = E_ALL | E_STRICT)',
  ),
  'set_exception_handler' => 
  array (
    'name' => 'set_exception_handler',
    'title' => '设置一个用户定义的异常处理函数。',
    'ret' => 'callable',
    'prot' => 'callable set_exception_handler(callable $exception_handler)',
  ),
  'trigger_error' => 
  array (
    'name' => 'trigger_error',
    'title' => '产生一个用户级别的 error/warning/notice 信息',
    'ret' => 'bool',
    'prot' => 'bool trigger_error(string $error_msg, int $error_type = E_USER_NOTICE)',
  ),
  'user_error' => 
  array (
    'name' => 'user_error',
    'title' => 'trigger_error 的别名',
    'ret' => 'bool',
    'prot' => 'bool user_error(string $error_msg, int $error_type = E_USER_NOTICE)',
  ),
  'exif_imagetype' => 
  array (
    'name' => 'exif_imagetype',
    'title' => '判断一个图像的类型',
    'ret' => 'int',
    'prot' => 'int exif_imagetype(string $filename)',
  ),
  'exif_read_data' => 
  array (
    'name' => 'exif_read_data',
    'title' => '从 JPEG 或 TIFF
   文件中读取 EXIF 头信息',
    'ret' => 'array',
    'prot' => 'array exif_read_data(string $filename, string $sections = &null;, bool $arrays = false, bool $thumbnail = false)',
  ),
  'exif_thumbnail' => 
  array (
    'name' => 'exif_thumbnail',
    'title' => '取得嵌入在 TIFF 或 JPEG 图像中的缩略图',
    'ret' => 'string',
    'prot' => 'string exif_thumbnail(string $filename, intwidth, intheight, intimagetype)',
  ),
  'read_exif_data' => 
  array (
    'name' => 'read_exif_data',
    'title' => '&Alias; exif_read_data',
    'ret' => 'string',
    'prot' => 'string read_exif_data(string $filename, intwidth, intheight, intimagetype)',
  ),
  'basename' => 
  array (
    'name' => 'basename',
    'title' => '返回路径中的文件名部分',
    'ret' => 'string',
    'prot' => 'string basename(string $path, string $suffix)',
  ),
  'chgrp' => 
  array (
    'name' => 'chgrp',
    'title' => '改变文件所属的组',
    'ret' => 'bool',
    'prot' => 'bool chgrp(string $filename, mixed $group)',
  ),
  'chmod' => 
  array (
    'name' => 'chmod',
    'title' => '改变文件模式',
    'ret' => 'bool',
    'prot' => 'bool chmod(string $filename, int $mode)',
  ),
  'chown' => 
  array (
    'name' => 'chown',
    'title' => '改变文件的所有者',
    'ret' => 'bool',
    'prot' => 'bool chown(string $filename, mixed $user)',
  ),
  'clearstatcache' => 
  array (
    'name' => 'clearstatcache',
    'title' => '清除文件状态缓存',
    'ret' => 'void',
    'prot' => 'void clearstatcache(bool $clear_realpath_cache = false, string $filename)',
  ),
  'copy' => 
  array (
    'name' => 'copy',
    'title' => '拷贝文件',
    'ret' => 'bool',
    'prot' => 'bool copy(string $source, string $dest, resource $context)',
  ),
  'delete' => 
  array (
    'name' => 'delete',
    'title' => '参见 unlink 或 unset',
    'ret' => 'void',
    'prot' => 'void delete()',
  ),
  'dirname' => 
  array (
    'name' => 'dirname',
    'title' => '返回路径中的目录部分',
    'ret' => 'string',
    'prot' => 'string dirname(string $path)',
  ),
  'disk_free_space' => 
  array (
    'name' => 'disk_free_space',
    'title' => '返回目录中的可用空间',
    'ret' => 'float',
    'prot' => 'float disk_free_space(string $directory)',
  ),
  'disk_total_space' => 
  array (
    'name' => 'disk_total_space',
    'title' => '返回一个目录的磁盘总大小',
    'ret' => 'float',
    'prot' => 'float disk_total_space(string $directory)',
  ),
  'diskfreespace' => 
  array (
    'name' => 'diskfreespace',
    'title' => 'disk_free_space 的&Alias;',
    'ret' => 'float',
    'prot' => 'float diskfreespace(string $directory)',
  ),
  'fclose' => 
  array (
    'name' => 'fclose',
    'title' => '关闭一个已打开的文件指针',
    'ret' => 'bool',
    'prot' => 'bool fclose(resource $handle)',
  ),
  'feof' => 
  array (
    'name' => 'feof',
    'title' => '测试文件指针是否到了文件结束的位置',
    'ret' => 'bool',
    'prot' => 'bool feof(resource $handle)',
  ),
  'fflush' => 
  array (
    'name' => 'fflush',
    'title' => '将缓冲内容输出到文件',
    'ret' => 'bool',
    'prot' => 'bool fflush(resource $handle)',
  ),
  'fgetc' => 
  array (
    'name' => 'fgetc',
    'title' => '从文件指针中读取字符',
    'ret' => 'string',
    'prot' => 'string fgetc(resource $handle)',
  ),
  'fgetcsv' => 
  array (
    'name' => 'fgetcsv',
    'title' => '从文件指针中读入一行并解析 CSV 字段',
    'ret' => 'array',
    'prot' => 'array fgetcsv(resource $handle, int $length = 0, string $delimiter = \',\', string $enclosure = \'"\', string $escape = \'\\\\\')',
  ),
  'fgets' => 
  array (
    'name' => 'fgets',
    'title' => '从文件指针中读取一行',
    'ret' => 'string',
    'prot' => 'string fgets(resource $handle, int $length)',
  ),
  'fgetss' => 
  array (
    'name' => 'fgetss',
    'title' => '从文件指针中读取一行并过滤掉 HTML 标记',
    'ret' => 'string',
    'prot' => 'string fgetss(resource $handle, int $length, string $allowable_tags)',
  ),
  'file_exists' => 
  array (
    'name' => 'file_exists',
    'title' => '检查文件或目录是否存在',
    'ret' => 'bool',
    'prot' => 'bool file_exists(string $filename)',
  ),
  'file_get_contents' => 
  array (
    'name' => 'file_get_contents',
    'title' => '将整个文件读入一个字符串',
    'ret' => 'string',
    'prot' => 'string file_get_contents(string $filename, bool $use_include_path = false, resource $context, int $offset = -1, int $maxlen)',
  ),
  'file_put_contents' => 
  array (
    'name' => 'file_put_contents',
    'title' => '将一个字符串写入文件',
    'ret' => 'int',
    'prot' => 'int file_put_contents(string $filename, mixed $data, int $flags = 0, resource $context)',
  ),
  'file' => 
  array (
    'name' => 'file',
    'title' => '把整个文件读入一个数组中',
    'ret' => 'array',
    'prot' => 'array file(string $filename, int $flags = 0, resource $context)',
  ),
  'fileatime' => 
  array (
    'name' => 'fileatime',
    'title' => '取得文件的上次访问时间',
    'ret' => 'int',
    'prot' => 'int fileatime(string $filename)',
  ),
  'filectime' => 
  array (
    'name' => 'filectime',
    'title' => '取得文件的 inode 修改时间',
    'ret' => 'int',
    'prot' => 'int filectime(string $filename)',
  ),
  'filegroup' => 
  array (
    'name' => 'filegroup',
    'title' => '取得文件的组',
    'ret' => 'int',
    'prot' => 'int filegroup(string $filename)',
  ),
  'fileinode' => 
  array (
    'name' => 'fileinode',
    'title' => '取得文件的 inode',
    'ret' => 'int',
    'prot' => 'int fileinode(string $filename)',
  ),
  'filemtime' => 
  array (
    'name' => 'filemtime',
    'title' => '取得文件修改时间',
    'ret' => 'int',
    'prot' => 'int filemtime(string $filename)',
  ),
  'fileowner' => 
  array (
    'name' => 'fileowner',
    'title' => '取得文件的所有者',
    'ret' => 'int',
    'prot' => 'int fileowner(string $filename)',
  ),
  'fileperms' => 
  array (
    'name' => 'fileperms',
    'title' => '取得文件的权限',
    'ret' => 'int',
    'prot' => 'int fileperms(string $filename)',
  ),
  'filesize' => 
  array (
    'name' => 'filesize',
    'title' => '取得文件大小',
    'ret' => 'int',
    'prot' => 'int filesize(string $filename)',
  ),
  'filetype' => 
  array (
    'name' => 'filetype',
    'title' => '取得文件类型',
    'ret' => 'string',
    'prot' => 'string filetype(string $filename)',
  ),
  'flock' => 
  array (
    'name' => 'flock',
    'title' => '轻便的咨询文件锁定',
    'ret' => 'bool',
    'prot' => 'bool flock(resource $handle, int $operation, intwouldblock)',
  ),
  'fnmatch' => 
  array (
    'name' => 'fnmatch',
    'title' => '用模式匹配文件名',
    'ret' => 'bool',
    'prot' => 'bool fnmatch(string $pattern, string $string, int $flags = 0)',
  ),
  'fopen' => 
  array (
    'name' => 'fopen',
    'title' => '打开文件或者 URL',
    'ret' => 'resource',
    'prot' => 'resource fopen(string $filename, string $mode, bool $use_include_path = false, resource $context)',
  ),
  'fpassthru' => 
  array (
    'name' => 'fpassthru',
    'title' => '输出文件指针处的所有剩余数据',
    'ret' => 'int',
    'prot' => 'int fpassthru(resource $handle)',
  ),
  'fputcsv' => 
  array (
    'name' => 'fputcsv',
    'title' => '将行格式化为 CSV 并写入文件指针',
    'ret' => 'int',
    'prot' => 'int fputcsv(resource $handle, array $fields, string $delimiter = \',\', string $enclosure = \'"\')',
  ),
  'fputs' => 
  array (
    'name' => 'fputs',
    'title' => 'fwrite 的&Alias;',
    'ret' => 'int',
    'prot' => 'int fputs(resource $handle, array $fields, string $delimiter = \',\', string $enclosure = \'"\')',
  ),
  'fread' => 
  array (
    'name' => 'fread',
    'title' => '读取文件（可安全用于二进制文件）',
    'ret' => 'string',
    'prot' => 'string fread(resource $handle, int $length)',
  ),
  'fscanf' => 
  array (
    'name' => 'fscanf',
    'title' => '从文件中格式化输入',
    'ret' => 'mixed',
    'prot' => 'mixed fscanf(resource $handle, string $format, mixed...)',
  ),
  'fseek' => 
  array (
    'name' => 'fseek',
    'title' => '在文件指针中定位',
    'ret' => 'int',
    'prot' => 'int fseek(resource $handle, int $offset, int $whence = SEEK_SET)',
  ),
  'fstat' => 
  array (
    'name' => 'fstat',
    'title' => '通过已打开的文件指针取得文件信息',
    'ret' => 'array',
    'prot' => 'array fstat(resource $handle)',
  ),
  'ftell' => 
  array (
    'name' => 'ftell',
    'title' => '返回文件指针读/写的位置',
    'ret' => 'int',
    'prot' => 'int ftell(resource $handle)',
  ),
  'ftruncate' => 
  array (
    'name' => 'ftruncate',
    'title' => '将文件截断到给定的长度',
    'ret' => 'bool',
    'prot' => 'bool ftruncate(resource $handle, int $size)',
  ),
  'fwrite' => 
  array (
    'name' => 'fwrite',
    'title' => '写入文件（可安全用于二进制文件）',
    'ret' => 'int',
    'prot' => 'int fwrite(resource $handle, string $string, int $length)',
  ),
  'glob' => 
  array (
    'name' => 'glob',
    'title' => '寻找与模式匹配的文件路径',
    'ret' => 'array',
    'prot' => 'array glob(string $pattern, int $flags = 0)',
  ),
  'is_dir' => 
  array (
    'name' => 'is_dir',
    'title' => '判断给定文件名是否是一个目录',
    'ret' => 'bool',
    'prot' => 'bool is_dir(string $filename)',
  ),
  'is_executable' => 
  array (
    'name' => 'is_executable',
    'title' => '判断给定文件名是否可执行',
    'ret' => 'bool',
    'prot' => 'bool is_executable(string $filename)',
  ),
  'is_file' => 
  array (
    'name' => 'is_file',
    'title' => '判断给定文件名是否为一个正常的文件',
    'ret' => 'bool',
    'prot' => 'bool is_file(string $filename)',
  ),
  'is_link' => 
  array (
    'name' => 'is_link',
    'title' => '判断给定文件名是否为一个符号连接',
    'ret' => 'bool',
    'prot' => 'bool is_link(string $filename)',
  ),
  'is_readable' => 
  array (
    'name' => 'is_readable',
    'title' => '判断给定文件名是否可读',
    'ret' => 'bool',
    'prot' => 'bool is_readable(string $filename)',
  ),
  'is_uploaded_file' => 
  array (
    'name' => 'is_uploaded_file',
    'title' => '判断文件是否是通过 HTTP POST 上传的',
    'ret' => 'bool',
    'prot' => 'bool is_uploaded_file(string $filename)',
  ),
  'is_writable' => 
  array (
    'name' => 'is_writable',
    'title' => '判断给定的文件名是否可写',
    'ret' => 'bool',
    'prot' => 'bool is_writable(string $filename)',
  ),
  'is_writeable' => 
  array (
    'name' => 'is_writeable',
    'title' => 'is_writable 的&Alias;',
    'ret' => 'bool',
    'prot' => 'bool is_writeable(string $filename)',
  ),
  'link' => 
  array (
    'name' => 'link',
    'title' => '建立一个硬连接',
    'ret' => 'bool',
    'prot' => 'bool link(string $target, string $link)',
  ),
  'linkinfo' => 
  array (
    'name' => 'linkinfo',
    'title' => '获取一个连接的信息',
    'ret' => 'int',
    'prot' => 'int linkinfo(string $path)',
  ),
  'lstat' => 
  array (
    'name' => 'lstat',
    'title' => '给出一个文件或符号连接的信息',
    'ret' => 'array',
    'prot' => 'array lstat(string $filename)',
  ),
  'mkdir' => 
  array (
    'name' => 'mkdir',
    'title' => '新建目录',
    'ret' => 'bool',
    'prot' => 'bool mkdir(string $pathname, int $mode = 0777, bool $recursive = false, resource $context)',
  ),
  'move_uploaded_file' => 
  array (
    'name' => 'move_uploaded_file',
    'title' => '将上传的文件移动到新位置',
    'ret' => 'bool',
    'prot' => 'bool move_uploaded_file(string $filename, string $destination)',
  ),
  'parse_ini_file' => 
  array (
    'name' => 'parse_ini_file',
    'title' => '解析一个配置文件',
    'ret' => 'array',
    'prot' => 'array parse_ini_file(string $filename, bool $process_sections = false, int $scanner_mode = INI_SCANNER_NORMAL)',
  ),
  'pathinfo' => 
  array (
    'name' => 'pathinfo',
    'title' => '返回文件路径的信息',
    'ret' => 'mixed',
    'prot' => 'mixed pathinfo(string $path, int $options = PATHINFO_DIRNAME | PATHINFO_BASENAME | PATHINFO_EXTENSION | PATHINFO_FILENAME)',
  ),
  'pclose' => 
  array (
    'name' => 'pclose',
    'title' => '关闭进程文件指针',
    'ret' => 'int',
    'prot' => 'int pclose(resource $handle)',
  ),
  'popen' => 
  array (
    'name' => 'popen',
    'title' => '打开进程文件指针',
    'ret' => 'resource',
    'prot' => 'resource popen(string $command, string $mode)',
  ),
  'readfile' => 
  array (
    'name' => 'readfile',
    'title' => '输出一个文件',
    'ret' => 'int',
    'prot' => 'int readfile(string $filename, bool $use_include_path = false, resource $context)',
  ),
  'readlink' => 
  array (
    'name' => 'readlink',
    'title' => '返回符号连接指向的目标',
    'ret' => 'string',
    'prot' => 'string readlink(string $path)',
  ),
  'realpath' => 
  array (
    'name' => 'realpath',
    'title' => '返回规范化的绝对路径名',
    'ret' => 'string',
    'prot' => 'string realpath(string $path)',
  ),
  'rename' => 
  array (
    'name' => 'rename',
    'title' => '重命名一个文件或目录',
    'ret' => 'bool',
    'prot' => 'bool rename(string $oldname, string $newname, resource $context)',
  ),
  'rewind' => 
  array (
    'name' => 'rewind',
    'title' => '倒回文件指针的位置',
    'ret' => 'bool',
    'prot' => 'bool rewind(resource $handle)',
  ),
  'rmdir' => 
  array (
    'name' => 'rmdir',
    'title' => '删除目录',
    'ret' => 'bool',
    'prot' => 'bool rmdir(string $dirname, resource $context)',
  ),
  'set_file_buffer' => 
  array (
    'name' => 'set_file_buffer',
    'title' => 'stream_set_write_buffer 的&Alias;',
    'ret' => 'bool',
    'prot' => 'bool set_file_buffer(string $dirname, resource $context)',
  ),
  'stat' => 
  array (
    'name' => 'stat',
    'title' => '给出文件的信息',
    'ret' => 'array',
    'prot' => 'array stat(string $filename)',
  ),
  'symlink' => 
  array (
    'name' => 'symlink',
    'title' => '建立符号连接',
    'ret' => 'bool',
    'prot' => 'bool symlink(string $target, string $link)',
  ),
  'tempnam' => 
  array (
    'name' => 'tempnam',
    'title' => '建立一个具有唯一文件名的文件',
    'ret' => 'string',
    'prot' => 'string tempnam(string $dir, string $prefix)',
  ),
  'tmpfile' => 
  array (
    'name' => 'tmpfile',
    'title' => '建立一个临时文件',
    'ret' => 'resource',
    'prot' => 'resource tmpfile()',
  ),
  'touch' => 
  array (
    'name' => 'touch',
    'title' => '设定文件的访问和修改时间',
    'ret' => 'bool',
    'prot' => 'bool touch(string $filename, int $time = time(), int $atime)',
  ),
  'umask' => 
  array (
    'name' => 'umask',
    'title' => '改变当前的 umask',
    'ret' => 'int',
    'prot' => 'int umask(int $mask)',
  ),
  'unlink' => 
  array (
    'name' => 'unlink',
    'title' => '删除文件',
    'ret' => 'bool',
    'prot' => 'bool unlink(string $filename, resource $context)',
  ),
  'ftp_cdup' => 
  array (
    'name' => 'ftp_cdup',
    'title' => '切换到当前目录的父目录',
    'ret' => 'bool',
    'prot' => 'bool ftp_cdup(resource $ftp_stream)',
  ),
  'ftp_chdir' => 
  array (
    'name' => 'ftp_chdir',
    'title' => '在 FTP 服务器上改变当前目录',
    'ret' => 'bool',
    'prot' => 'bool ftp_chdir(resource $ftp_stream, string $directory)',
  ),
  'ftp_close' => 
  array (
    'name' => 'ftp_close',
    'title' => '关闭一个 FTP 连接',
    'ret' => 'bool',
    'prot' => 'bool ftp_close(resource $ftp_stream)',
  ),
  'ftp_connect' => 
  array (
    'name' => 'ftp_connect',
    'title' => '建立一个新的 FTP 连接',
    'ret' => 'resource',
    'prot' => 'resource ftp_connect(string $host, int $port, int $timeout)',
  ),
  'ftp_delete' => 
  array (
    'name' => 'ftp_delete',
    'title' => '删除 FTP 服务器上的一个文件',
    'ret' => 'bool',
    'prot' => 'bool ftp_delete(resource $ftp_stream, string $path)',
  ),
  'ftp_exec' => 
  array (
    'name' => 'ftp_exec',
    'title' => '请求运行一条 FTP 命令',
    'ret' => 'bool',
    'prot' => 'bool ftp_exec(resource $ftp_stream, string $command)',
  ),
  'ftp_fget' => 
  array (
    'name' => 'ftp_fget',
    'title' => '从 FTP 服务器上下载一个文件并保存到本地一个已经打开的文件中',
    'ret' => 'bool',
    'prot' => 'bool ftp_fget(resource $ftp_stream, resource $handle, string $remote_file, int $mode, int $resumepos = 0)',
  ),
  'ftp_fput' => 
  array (
    'name' => 'ftp_fput',
    'title' => '上传一个已经打开的文件到 FTP 服务器',
    'ret' => 'bool',
    'prot' => 'bool ftp_fput(resource $ftp_stream, string $remote_file, resource $handle, int $mode, int $startpos = 0)',
  ),
  'ftp_get_option' => 
  array (
    'name' => 'ftp_get_option',
    'title' => '返回当前 FTP 连接的各种不同的选项设置',
    'ret' => 'mixed',
    'prot' => 'mixed ftp_get_option(resource $ftp_stream, int $option)',
  ),
  'ftp_get' => 
  array (
    'name' => 'ftp_get',
    'title' => '从 FTP 服务器上下载一个文件',
    'ret' => 'bool',
    'prot' => 'bool ftp_get(resource $ftp_stream, string $local_file, string $remote_file, int $mode, int $resumepos = 0)',
  ),
  'ftp_login' => 
  array (
    'name' => 'ftp_login',
    'title' => '登录 FTP 服务器',
    'ret' => 'bool',
    'prot' => 'bool ftp_login(resource $ftp_stream, string $username, string $password)',
  ),
  'ftp_mdtm' => 
  array (
    'name' => 'ftp_mdtm',
    'title' => '返回指定文件的最后修改时间',
    'ret' => 'int',
    'prot' => 'int ftp_mdtm(resource $ftp_stream, string $remote_file)',
  ),
  'ftp_mkdir' => 
  array (
    'name' => 'ftp_mkdir',
    'title' => '建立新目录',
    'ret' => 'string',
    'prot' => 'string ftp_mkdir(resource $ftp_stream, string $directory)',
  ),
  'ftp_nb_continue' => 
  array (
    'name' => 'ftp_nb_continue',
    'title' => '连续获取／发送文件（non-blocking）',
    'ret' => 'int',
    'prot' => 'int ftp_nb_continue(resource $ftp_stream)',
  ),
  'ftp_nb_get' => 
  array (
    'name' => 'ftp_nb_get',
    'title' => '从 FTP 服务器上获取文件并写入本地文件（non-blocking）',
    'ret' => 'bool',
    'prot' => 'bool ftp_nb_get(resource $ftp_stream, string $local_file, string $remote_file, int $mode, int $resumepos)',
  ),
  'ftp_nb_put' => 
  array (
    'name' => 'ftp_nb_put',
    'title' => '存储一个文件至 FTP 服务器（non-blocking）',
    'ret' => 'int',
    'prot' => 'int ftp_nb_put(resource $ftp_stream, string $remote_file, string $local_file, int $mode, int $startpos)',
  ),
  'ftp_nlist' => 
  array (
    'name' => 'ftp_nlist',
    'title' => '返回给定目录的文件列表',
    'ret' => 'array',
    'prot' => 'array ftp_nlist(resource $ftp_stream, string $directory)',
  ),
  'ftp_pasv' => 
  array (
    'name' => 'ftp_pasv',
    'title' => '返回当前 FTP 被动模式是否打开',
    'ret' => 'bool',
    'prot' => 'bool ftp_pasv(resource $ftp_stream, bool $pasv)',
  ),
  'ftp_put' => 
  array (
    'name' => 'ftp_put',
    'title' => '上传文件到 FTP 服务器',
    'ret' => 'bool',
    'prot' => 'bool ftp_put(resource $ftp_stream, string $remote_file, string $local_file, int $mode, int $startpos)',
  ),
  'ftp_pwd' => 
  array (
    'name' => 'ftp_pwd',
    'title' => '返回当前目录名',
    'ret' => 'string',
    'prot' => 'string ftp_pwd(resource $ftp_stream)',
  ),
  'ftp_quit' => 
  array (
    'name' => 'ftp_quit',
    'title' => 'ftp_close 的 &Alias;',
    'ret' => 'string',
    'prot' => 'string ftp_quit(resource $ftp_stream)',
  ),
  'ftp_rawlist' => 
  array (
    'name' => 'ftp_rawlist',
    'title' => '返回指定目录下文件的详细列表',
    'ret' => 'array',
    'prot' => 'array ftp_rawlist(resource $ftp_stream, string $directory)',
  ),
  'ftp_rename' => 
  array (
    'name' => 'ftp_rename',
    'title' => '更改 FTP 服务器上的文件或目录名',
    'ret' => 'bool',
    'prot' => 'bool ftp_rename(resource $ftp_stream, string $oldname, string $newname)',
  ),
  'ftp_rmdir' => 
  array (
    'name' => 'ftp_rmdir',
    'title' => '删除 FTP 服务器上的一个目录',
    'ret' => 'bool',
    'prot' => 'bool ftp_rmdir(resource $ftp_stream, string $directory)',
  ),
  'ftp_set_option' => 
  array (
    'name' => 'ftp_set_option',
    'title' => '设置各种 FTP 运行时选项',
    'ret' => 'bool',
    'prot' => 'bool ftp_set_option(resource $ftp_stream, int $option, mixed $value)',
  ),
  'ftp_site' => 
  array (
    'name' => 'ftp_site',
    'title' => '向服务器发送 SITE 命令',
    'ret' => 'bool',
    'prot' => 'bool ftp_site(resource $ftp_stream, string $cmd)',
  ),
  'ftp_size' => 
  array (
    'name' => 'ftp_size',
    'title' => '返回指定文件的大小',
    'ret' => 'int',
    'prot' => 'int ftp_size(resource $ftp_stream, string $remote_file)',
  ),
  'ftp_systype' => 
  array (
    'name' => 'ftp_systype',
    'title' => '返回远程 FTP 服务器的操作系统类型',
    'ret' => 'string',
    'prot' => 'string ftp_systype(resource $ftp_stream)',
  ),
  'http_build_str' => 
  array (
    'name' => 'http_build_str',
    'title' => '产生一个查询字符串',
    'ret' => 'string',
    'prot' => 'string http_build_str(array $query, string $prefix, string $arg_separator = ini_get("arg_separator.output"))',
  ),
  'http_build_url' => 
  array (
    'name' => 'http_build_url',
    'title' => '产生一个 URL',
    'ret' => 'string',
    'prot' => 'string http_build_url(mixed $url, mixed $parts, int $flags = HTTP_URL_REPLACE, arraynew_url)',
  ),
  'iconv_get_encoding' => 
  array (
    'name' => 'iconv_get_encoding',
    'title' => '获取 iconv 扩展的内部配置变量',
    'ret' => 'mixed',
    'prot' => 'mixed iconv_get_encoding(string $type = "all")',
  ),
  'iconv_mime_decode_headers' => 
  array (
    'name' => 'iconv_mime_decode_headers',
    'title' => '一次性解码多个 MIME 头字段',
    'ret' => 'array',
    'prot' => 'array iconv_mime_decode_headers(string $encoded_headers, int $mode = 0, string $charset = ini_get("iconv.internal_encoding"))',
  ),
  'iconv_set_encoding' => 
  array (
    'name' => 'iconv_set_encoding',
    'title' => '为字符编码转换设定当前设置',
    'ret' => 'bool',
    'prot' => 'bool iconv_set_encoding(string $type, string $charset)',
  ),
  'iconv_strlen' => 
  array (
    'name' => 'iconv_strlen',
    'title' => '返回字符串的字符数统计',
    'ret' => 'int',
    'prot' => 'int iconv_strlen(string $str, string $charset = ini_get("iconv.internal_encoding"))',
  ),
  'iconv_substr' => 
  array (
    'name' => 'iconv_substr',
    'title' => '截取字符串的部分',
    'ret' => 'string',
    'prot' => 'string iconv_substr(string $str, int $offset, int $length = iconv_strlen($str, $charset), string $charset = ini_get("iconv.internal_encoding"))',
  ),
  'iconv' => 
  array (
    'name' => 'iconv',
    'title' => '字符串按要求的字符编码来转换',
    'ret' => 'string',
    'prot' => 'string iconv(string $in_charset, string $out_charset, string $str)',
  ),
  'ob_iconv_handler' => 
  array (
    'name' => 'ob_iconv_handler',
    'title' => '以输出缓冲处理程序转换字符编码',
    'ret' => 'string',
    'prot' => 'string ob_iconv_handler(string $contents, int $status)',
  ),
  'gd_info' => 
  array (
    'name' => 'gd_info',
    'title' => '取得当前安装的 GD 库的信息',
    'ret' => 'array',
    'prot' => 'array gd_info()',
  ),
  'getimagesize' => 
  array (
    'name' => 'getimagesize',
    'title' => '取得图像大小',
    'ret' => 'array',
    'prot' => 'array getimagesize(string $filename, arrayimageinfo)',
  ),
  'image_type_to_extension' => 
  array (
    'name' => 'image_type_to_extension',
    'title' => '取得图像类型的文件后缀',
    'ret' => 'string',
    'prot' => 'string image_type_to_extension(int $imagetype, bool $include_dot = &true;)',
  ),
  'image_type_to_mime_type' => 
  array (
    'name' => 'image_type_to_mime_type',
    'title' => '取得 getimagesize，exif_read_data，exif_thumbnail，exif_imagetype
    所返回的图像类型的 MIME 类型',
    'ret' => 'string',
    'prot' => 'string image_type_to_mime_type(int $imagetype)',
  ),
  'image2wbmp' => 
  array (
    'name' => 'image2wbmp',
    'title' => '以 WBMP 格式将图像输出到浏览器或文件',
    'ret' => 'int',
    'prot' => 'int image2wbmp(resource $image, string $filename, int $threshold)',
  ),
  'imagealphablending' => 
  array (
    'name' => 'imagealphablending',
    'title' => '设定图像的混色模式',
    'ret' => 'bool',
    'prot' => 'bool imagealphablending(resource $image, bool $blendmode)',
  ),
  'imageantialias' => 
  array (
    'name' => 'imageantialias',
    'title' => '是否使用抗锯齿（antialias）功能',
    'ret' => 'bool',
    'prot' => 'bool imageantialias(resource $image, bool $enabled)',
  ),
  'imagearc' => 
  array (
    'name' => 'imagearc',
    'title' => '画椭圆弧',
    'ret' => 'bool',
    'prot' => 'bool imagearc(resource $image, int $cx, int $cy, int $w, int $h, int $s, int $e, int $color)',
  ),
  'imagechar' => 
  array (
    'name' => 'imagechar',
    'title' => '水平地画一个字符',
    'ret' => 'bool',
    'prot' => 'bool imagechar(resource $image, int $font, int $x, int $y, string $c, int $color)',
  ),
  'imagecharup' => 
  array (
    'name' => 'imagecharup',
    'title' => '垂直地画一个字符',
    'ret' => 'bool',
    'prot' => 'bool imagecharup(resource $image, int $font, int $x, int $y, string $c, int $color)',
  ),
  'imagecolorallocate' => 
  array (
    'name' => 'imagecolorallocate',
    'title' => '为一幅图像分配颜色',
    'ret' => 'int',
    'prot' => 'int imagecolorallocate(resource $image, int $red, int $green, int $blue)',
  ),
  'imagecolorallocatealpha' => 
  array (
    'name' => 'imagecolorallocatealpha',
    'title' => '为一幅图像分配颜色 + alpha',
    'ret' => 'int',
    'prot' => 'int imagecolorallocatealpha(resource $image, int $red, int $green, int $blue, int $alpha)',
  ),
  'imagecolorat' => 
  array (
    'name' => 'imagecolorat',
    'title' => '取得某像素的颜色索引值',
    'ret' => 'int',
    'prot' => 'int imagecolorat(resource $image, int $x, int $y)',
  ),
  'imagecolorclosest' => 
  array (
    'name' => 'imagecolorclosest',
    'title' => '取得与指定的颜色最接近的颜色的索引值',
    'ret' => 'int',
    'prot' => 'int imagecolorclosest(resource $image, int $red, int $green, int $blue)',
  ),
  'imagecolorclosestalpha' => 
  array (
    'name' => 'imagecolorclosestalpha',
    'title' => '取得与指定的颜色加透明度最接近的颜色',
    'ret' => 'int',
    'prot' => 'int imagecolorclosestalpha(resource $image, int $red, int $green, int $blue, int $alpha)',
  ),
  'imagecolorclosesthwb' => 
  array (
    'name' => 'imagecolorclosesthwb',
    'title' => '取得与给定颜色最接近的色度的黑白色的索引',
    'ret' => 'int',
    'prot' => 'int imagecolorclosesthwb(resource $image, int $red, int $green, int $blue)',
  ),
  'imagecolordeallocate' => 
  array (
    'name' => 'imagecolordeallocate',
    'title' => '取消图像颜色的分配',
    'ret' => 'bool',
    'prot' => 'bool imagecolordeallocate(resource $image, int $color)',
  ),
  'imagecolorexact' => 
  array (
    'name' => 'imagecolorexact',
    'title' => '取得指定颜色的索引值',
    'ret' => 'int',
    'prot' => 'int imagecolorexact(resource $image, int $red, int $green, int $blue)',
  ),
  'imagecolorexactalpha' => 
  array (
    'name' => 'imagecolorexactalpha',
    'title' => '取得指定的颜色加透明度的索引值',
    'ret' => 'int',
    'prot' => 'int imagecolorexactalpha(resource $image, int $red, int $green, int $blue, int $alpha)',
  ),
  'imagecolormatch' => 
  array (
    'name' => 'imagecolormatch',
    'title' => '使一个图像中调色板版本的颜色与真彩色版本更能匹配',
    'ret' => 'bool',
    'prot' => 'bool imagecolormatch(resource $image1, resource $image2)',
  ),
  'imagecolorresolve' => 
  array (
    'name' => 'imagecolorresolve',
    'title' => '取得指定颜色的索引值或有可能得到的最接近的替代值',
    'ret' => 'int',
    'prot' => 'int imagecolorresolve(resource $image, int $red, int $green, int $blue)',
  ),
  'imagecolorresolvealpha' => 
  array (
    'name' => 'imagecolorresolvealpha',
    'title' => '取得指定颜色 + alpha 的索引值或有可能得到的最接近的替代值',
    'ret' => 'int',
    'prot' => 'int imagecolorresolvealpha(resource $image, int $red, int $green, int $blue, int $alpha)',
  ),
  'imagecolorset' => 
  array (
    'name' => 'imagecolorset',
    'title' => '给指定调色板索引设定颜色',
    'ret' => 'void',
    'prot' => 'void imagecolorset(resource $image, int $index, int $red, int $green, int $blue)',
  ),
  'imagecolorsforindex' => 
  array (
    'name' => 'imagecolorsforindex',
    'title' => '取得某索引的颜色',
    'ret' => 'array',
    'prot' => 'array imagecolorsforindex(resource $image, int $index)',
  ),
  'imagecolorstotal' => 
  array (
    'name' => 'imagecolorstotal',
    'title' => '取得一幅图像的调色板中颜色的数目',
    'ret' => 'int',
    'prot' => 'int imagecolorstotal(resource $image)',
  ),
  'imagecolortransparent' => 
  array (
    'name' => 'imagecolortransparent',
    'title' => '将某个颜色定义为透明色',
    'ret' => 'int',
    'prot' => 'int imagecolortransparent(resource $image, int $color)',
  ),
  'imageconvolution' => 
  array (
    'name' => 'imageconvolution',
    'title' => '用系数 div 和 offset 申请一个 3x3 的卷积矩阵',
    'ret' => 'bool',
    'prot' => 'bool imageconvolution(resource $image, array $matrix, float $div, float $offset)',
  ),
  'imagecopy' => 
  array (
    'name' => 'imagecopy',
    'title' => '拷贝图像的一部分',
    'ret' => 'bool',
    'prot' => 'bool imagecopy(resource $dst_im, resource $src_im, int $dst_x, int $dst_y, int $src_x, int $src_y, int $src_w, int $src_h)',
  ),
  'imagecopymerge' => 
  array (
    'name' => 'imagecopymerge',
    'title' => '拷贝并合并图像的一部分',
    'ret' => 'bool',
    'prot' => 'bool imagecopymerge(resource $dst_im, resource $src_im, int $dst_x, int $dst_y, int $src_x, int $src_y, int $src_w, int $src_h, int $pct)',
  ),
  'imagecopymergegray' => 
  array (
    'name' => 'imagecopymergegray',
    'title' => '用灰度拷贝并合并图像的一部分',
    'ret' => 'bool',
    'prot' => 'bool imagecopymergegray(resource $dst_im, resource $src_im, int $dst_x, int $dst_y, int $src_x, int $src_y, int $src_w, int $src_h, int $pct)',
  ),
  'imagecopyresampled' => 
  array (
    'name' => 'imagecopyresampled',
    'title' => '重采样拷贝部分图像并调整大小',
    'ret' => 'bool',
    'prot' => 'bool imagecopyresampled(resource $dst_image, resource $src_image, int $dst_x, int $dst_y, int $src_x, int $src_y, int $dst_w, int $dst_h, int $src_w, int $src_h)',
  ),
  'imagecopyresized' => 
  array (
    'name' => 'imagecopyresized',
    'title' => '拷贝部分图像并调整大小',
    'ret' => 'bool',
    'prot' => 'bool imagecopyresized(resource $dst_image, resource $src_image, int $dst_x, int $dst_y, int $src_x, int $src_y, int $dst_w, int $dst_h, int $src_w, int $src_h)',
  ),
  'imagecreate' => 
  array (
    'name' => 'imagecreate',
    'title' => '新建一个基于调色板的图像',
    'ret' => 'resource',
    'prot' => 'resource imagecreate(int $x_size, int $y_size)',
  ),
  'imagecreatefromgd' => 
  array (
    'name' => 'imagecreatefromgd',
    'title' => '从 GD 文件或 URL 新建一图像',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromgd(string $filename)',
  ),
  'imagecreatefromgd2' => 
  array (
    'name' => 'imagecreatefromgd2',
    'title' => '从 GD2 文件或 URL 新建一图像',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromgd2(string $filename)',
  ),
  'imagecreatefromgd2part' => 
  array (
    'name' => 'imagecreatefromgd2part',
    'title' => '从给定的 GD2 文件或 URL 中的部分新建一图像',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromgd2part(string $filename, int $srcX, int $srcY, int $width, int $height)',
  ),
  'imagecreatefromgif' => 
  array (
    'name' => 'imagecreatefromgif',
    'title' => '&gd.image.new;',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromgif(string $filename)',
  ),
  'imagecreatefromjpeg' => 
  array (
    'name' => 'imagecreatefromjpeg',
    'title' => '&gd.image.new;',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromjpeg(string $filename)',
  ),
  'imagecreatefrompng' => 
  array (
    'name' => 'imagecreatefrompng',
    'title' => '&gd.image.new;',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefrompng(string $filename)',
  ),
  'imagecreatefromstring' => 
  array (
    'name' => 'imagecreatefromstring',
    'title' => '从字符串中的图像流新建一图像',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromstring(string $image)',
  ),
  'imagecreatefromwbmp' => 
  array (
    'name' => 'imagecreatefromwbmp',
    'title' => '&gd.image.new;',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromwbmp(string $filename)',
  ),
  'imagecreatefromxbm' => 
  array (
    'name' => 'imagecreatefromxbm',
    'title' => '&gd.image.new;',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromxbm(string $filename)',
  ),
  'imagecreatefromxpm' => 
  array (
    'name' => 'imagecreatefromxpm',
    'title' => '&gd.image.new;',
    'ret' => 'resource',
    'prot' => 'resource imagecreatefromxpm(string $filename)',
  ),
  'imagecreatetruecolor' => 
  array (
    'name' => 'imagecreatetruecolor',
    'title' => '新建一个真彩色图像',
    'ret' => 'resource',
    'prot' => 'resource imagecreatetruecolor(int $width, int $height)',
  ),
  'imagedashedline' => 
  array (
    'name' => 'imagedashedline',
    'title' => '画一虚线',
    'ret' => 'bool',
    'prot' => 'bool imagedashedline(resource $image, int $x1, int $y1, int $x2, int $y2, int $color)',
  ),
  'imagedestroy' => 
  array (
    'name' => 'imagedestroy',
    'title' => '销毁一图像',
    'ret' => 'bool',
    'prot' => 'bool imagedestroy(resource $image)',
  ),
  'imageellipse' => 
  array (
    'name' => 'imageellipse',
    'title' => '画一个椭圆',
    'ret' => 'bool',
    'prot' => 'bool imageellipse(resource $image, int $cx, int $cy, int $width, int $height, int $color)',
  ),
  'imagefill' => 
  array (
    'name' => 'imagefill',
    'title' => '区域填充',
    'ret' => 'bool',
    'prot' => 'bool imagefill(resource $image, int $x, int $y, int $color)',
  ),
  'imagefilledarc' => 
  array (
    'name' => 'imagefilledarc',
    'title' => '画一椭圆弧且填充',
    'ret' => 'bool',
    'prot' => 'bool imagefilledarc(resource $image, int $cx, int $cy, int $width, int $height, int $start, int $end, int $color, int $style)',
  ),
  'imagefilledellipse' => 
  array (
    'name' => 'imagefilledellipse',
    'title' => '画一椭圆并填充',
    'ret' => 'bool',
    'prot' => 'bool imagefilledellipse(resource $image, int $cx, int $cy, int $width, int $height, int $color)',
  ),
  'imagefilledpolygon' => 
  array (
    'name' => 'imagefilledpolygon',
    'title' => '画一多边形并填充',
    'ret' => 'bool',
    'prot' => 'bool imagefilledpolygon(resource $image, array $points, int $num_points, int $color)',
  ),
  'imagefilledrectangle' => 
  array (
    'name' => 'imagefilledrectangle',
    'title' => '画一矩形并填充',
    'ret' => 'bool',
    'prot' => 'bool imagefilledrectangle(resource $image, int $x1, int $y1, int $x2, int $y2, int $color)',
  ),
  'imagefilltoborder' => 
  array (
    'name' => 'imagefilltoborder',
    'title' => '区域填充到指定颜色的边界为止',
    'ret' => 'bool',
    'prot' => 'bool imagefilltoborder(resource $image, int $x, int $y, int $border, int $color)',
  ),
  'imagefilter' => 
  array (
    'name' => 'imagefilter',
    'title' => '对图像使用过滤器',
    'ret' => 'bool',
    'prot' => 'bool imagefilter(resource $src_im, int $filtertype, int $arg1, int $arg2, int $arg3)',
  ),
  'imagefontheight' => 
  array (
    'name' => 'imagefontheight',
    'title' => '取得字体高度',
    'ret' => 'int',
    'prot' => 'int imagefontheight(int $font)',
  ),
  'imagefontwidth' => 
  array (
    'name' => 'imagefontwidth',
    'title' => '取得字体宽度',
    'ret' => 'int',
    'prot' => 'int imagefontwidth(int $font)',
  ),
  'imageftbbox' => 
  array (
    'name' => 'imageftbbox',
    'title' => '给出一个使用 FreeType 2 字体的文本框',
    'ret' => 'array',
    'prot' => 'array imageftbbox(float $size, float $angle, string $fontfile, string $text, array $extrainfo)',
  ),
  'imagefttext' => 
  array (
    'name' => 'imagefttext',
    'title' => '使用 FreeType 2 字体将文本写入图像',
    'ret' => 'array',
    'prot' => 'array imagefttext(resource $image, float $size, float $angle, int $x, int $y, int $color, string $fontfile, string $text, array $extrainfo)',
  ),
  'imagegammacorrect' => 
  array (
    'name' => 'imagegammacorrect',
    'title' => '对 GD 图像应用 gamma 修正',
    'ret' => 'bool',
    'prot' => 'bool imagegammacorrect(resource $image, float $inputgamma, float $outputgamma)',
  ),
  'imagegd' => 
  array (
    'name' => 'imagegd',
    'title' => '将 GD 图像输出到浏览器或文件',
    'ret' => 'bool',
    'prot' => 'bool imagegd(resource $image, string $filename)',
  ),
  'imagegd2' => 
  array (
    'name' => 'imagegd2',
    'title' => '将 GD2 图像输出到浏览器或文件',
    'ret' => 'bool',
    'prot' => 'bool imagegd2(resource $image, string $filename, int $chunk_size, int $type = IMG_GD2_RAW)',
  ),
  'imagegif' => 
  array (
    'name' => 'imagegif',
    'title' => '&gd.image.output;',
    'ret' => 'bool',
    'prot' => 'bool imagegif(resource $image, string $filename)',
  ),
  'imageinterlace' => 
  array (
    'name' => 'imageinterlace',
    'title' => '激活或禁止隔行扫描',
    'ret' => 'int',
    'prot' => 'int imageinterlace(resource $image, int $interlace)',
  ),
  'imageistruecolor' => 
  array (
    'name' => 'imageistruecolor',
    'title' => '检查图像是否为真彩色图像',
    'ret' => 'bool',
    'prot' => 'bool imageistruecolor(resource $image)',
  ),
  'imagejpeg' => 
  array (
    'name' => 'imagejpeg',
    'title' => '&gd.image.output;',
    'ret' => 'bool',
    'prot' => 'bool imagejpeg(resource $image, string $filename, int $quality)',
  ),
  'imagelayereffect' => 
  array (
    'name' => 'imagelayereffect',
    'title' => '设定 alpha 混色标志以使用绑定的 libgd 分层效果',
    'ret' => 'bool',
    'prot' => 'bool imagelayereffect(resource $image, int $effect)',
  ),
  'imageline' => 
  array (
    'name' => 'imageline',
    'title' => '画一条线段',
    'ret' => 'bool',
    'prot' => 'bool imageline(resource $image, int $x1, int $y1, int $x2, int $y2, int $color)',
  ),
  'imageloadfont' => 
  array (
    'name' => 'imageloadfont',
    'title' => '载入一新字体',
    'ret' => 'int',
    'prot' => 'int imageloadfont(string $file)',
  ),
  'imagepalettecopy' => 
  array (
    'name' => 'imagepalettecopy',
    'title' => '将调色板从一幅图像拷贝到另一幅',
    'ret' => 'void',
    'prot' => 'void imagepalettecopy(resource $destination, resource $source)',
  ),
  'imagepng' => 
  array (
    'name' => 'imagepng',
    'title' => '以 PNG 格式将图像输出到浏览器或文件',
    'ret' => 'bool',
    'prot' => 'bool imagepng(resource $image, string $filename)',
  ),
  'imagepolygon' => 
  array (
    'name' => 'imagepolygon',
    'title' => '画一个多边形',
    'ret' => 'bool',
    'prot' => 'bool imagepolygon(resource $image, array $points, int $num_points, int $color)',
  ),
  'imagepsbbox' => 
  array (
    'name' => 'imagepsbbox',
    'title' => '给出一个使用 PostScript Type1 字体的文本方框',
    'ret' => 'array',
    'prot' => 'array imagepsbbox(string $text, resource $font, int $size)',
  ),
  'imagepsencodefont' => 
  array (
    'name' => 'imagepsencodefont',
    'title' => '改变字体中的字符编码矢量',
    'ret' => 'bool',
    'prot' => 'bool imagepsencodefont(resource $font_index, string $encodingfile)',
  ),
  'imagepsextendfont' => 
  array (
    'name' => 'imagepsextendfont',
    'title' => '扩充或精简字体',
    'ret' => 'bool',
    'prot' => 'bool imagepsextendfont(resource $font_index, float $extend)',
  ),
  'imagepsfreefont' => 
  array (
    'name' => 'imagepsfreefont',
    'title' => '释放一个 PostScript Type 1 字体所占用的内存',
    'ret' => 'bool',
    'prot' => 'bool imagepsfreefont(resource $font_index)',
  ),
  'imagepsloadfont' => 
  array (
    'name' => 'imagepsloadfont',
    'title' => '从文件中加载一个 PostScript Type 1 字体',
    'ret' => 'resource',
    'prot' => 'resource imagepsloadfont(string $filename)',
  ),
  'imagepsslantfont' => 
  array (
    'name' => 'imagepsslantfont',
    'title' => '倾斜某字体',
    'ret' => 'bool',
    'prot' => 'bool imagepsslantfont(resource $font_index, float $slant)',
  ),
  'imagepstext' => 
  array (
    'name' => 'imagepstext',
    'title' => '用 PostScript Type1 字体把文本字符串画在图像上',
    'ret' => 'array',
    'prot' => 'array imagepstext(resource $image, string $text, resource $font_index, int $size, int $foreground, int $background, int $x, int $y, int $space = 0, int $tightness = 0, float $angle = 0.0, int $antialias_steps = 4)',
  ),
  'imagerectangle' => 
  array (
    'name' => 'imagerectangle',
    'title' => '画一个矩形',
    'ret' => 'bool',
    'prot' => 'bool imagerectangle(resource $image, int $x1, int $y1, int $x2, int $y2, int $col)',
  ),
  'imagerotate' => 
  array (
    'name' => 'imagerotate',
    'title' => '用给定角度旋转图像',
    'ret' => 'resource',
    'prot' => 'resource imagerotate(resource $image, float $angle, int $bgd_color, int $ignore_transparent = 0)',
  ),
  'imagesavealpha' => 
  array (
    'name' => 'imagesavealpha',
    'title' => '设置标记以在保存 PNG 图像时保存完整的 alpha 通道信息（与单一透明色相反）',
    'ret' => 'bool',
    'prot' => 'bool imagesavealpha(resource $image, bool $saveflag)',
  ),
  'imagesetbrush' => 
  array (
    'name' => 'imagesetbrush',
    'title' => '设定画线用的画笔图像',
    'ret' => 'bool',
    'prot' => 'bool imagesetbrush(resource $image, resource $brush)',
  ),
  'imagesetpixel' => 
  array (
    'name' => 'imagesetpixel',
    'title' => '画一个单一像素',
    'ret' => 'bool',
    'prot' => 'bool imagesetpixel(resource $image, int $x, int $y, int $color)',
  ),
  'imagesetstyle' => 
  array (
    'name' => 'imagesetstyle',
    'title' => '设定画线的风格',
    'ret' => 'bool',
    'prot' => 'bool imagesetstyle(resource $image, array $style)',
  ),
  'imagesetthickness' => 
  array (
    'name' => 'imagesetthickness',
    'title' => '设定画线的宽度',
    'ret' => 'bool',
    'prot' => 'bool imagesetthickness(resource $image, int $thickness)',
  ),
  'imagesettile' => 
  array (
    'name' => 'imagesettile',
    'title' => '设定用于填充的贴图',
    'ret' => 'bool',
    'prot' => 'bool imagesettile(resource $image, resource $tile)',
  ),
  'imagestring' => 
  array (
    'name' => 'imagestring',
    'title' => '水平地画一行字符串',
    'ret' => 'bool',
    'prot' => 'bool imagestring(resource $image, int $font, int $x, int $y, string $s, int $col)',
  ),
  'imagestringup' => 
  array (
    'name' => 'imagestringup',
    'title' => '垂直地画一行字符串',
    'ret' => 'bool',
    'prot' => 'bool imagestringup(resource $image, int $font, int $x, int $y, string $s, int $col)',
  ),
  'imagesx' => 
  array (
    'name' => 'imagesx',
    'title' => '取得图像宽度',
    'ret' => 'int',
    'prot' => 'int imagesx(resource $image)',
  ),
  'imagesy' => 
  array (
    'name' => 'imagesy',
    'title' => '取得图像高度',
    'ret' => 'int',
    'prot' => 'int imagesy(resource $image)',
  ),
  'imagetruecolortopalette' => 
  array (
    'name' => 'imagetruecolortopalette',
    'title' => '将真彩色图像转换为调色板图像',
    'ret' => 'bool',
    'prot' => 'bool imagetruecolortopalette(resource $image, bool $dither, int $ncolors)',
  ),
  'imagettfbbox' => 
  array (
    'name' => 'imagettfbbox',
    'title' => '取得使用 TrueType 字体的文本的范围',
    'ret' => 'array',
    'prot' => 'array imagettfbbox(float $size, float $angle, string $fontfile, string $text)',
  ),
  'imagettftext' => 
  array (
    'name' => 'imagettftext',
    'title' => '用 TrueType 字体向图像写入文本',
    'ret' => 'array',
    'prot' => 'array imagettftext(resource $image, float $size, float $angle, int $x, int $y, int $color, string $fontfile, string $text)',
  ),
  'imagetypes' => 
  array (
    'name' => 'imagetypes',
    'title' => '返回当前 PHP 版本所支持的图像类型',
    'ret' => 'int',
    'prot' => 'int imagetypes()',
  ),
  'imagewbmp' => 
  array (
    'name' => 'imagewbmp',
    'title' => '以 WBMP 格式将图像输出到浏览器或文件',
    'ret' => 'bool',
    'prot' => 'bool imagewbmp(resource $image, string $filename, int $foreground)',
  ),
  'imagexbm' => 
  array (
    'name' => 'imagexbm',
    'title' => '将 XBM 图像输出到浏览器或文件',
    'ret' => 'bool',
    'prot' => 'bool imagexbm(resource $image, string $filename, int $foreground)',
  ),
  'iptcembed' => 
  array (
    'name' => 'iptcembed',
    'title' => '将二进制 IPTC 数据嵌入到一幅 JPEG 图像中',
    'ret' => 'mixed',
    'prot' => 'mixed iptcembed(string $iptcdata, string $jpeg_file_name, int $spool)',
  ),
  'iptcparse' => 
  array (
    'name' => 'iptcparse',
    'title' => '将二进制 IPTC 块解析为单个标记',
    'ret' => 'array',
    'prot' => 'array iptcparse(string $iptcblock)',
  ),
  'jpeg2wbmp' => 
  array (
    'name' => 'jpeg2wbmp',
    'title' => '将 JPEG 图像文件转换为 WBMP 图像文件',
    'ret' => 'bool',
    'prot' => 'bool jpeg2wbmp(string $jpegname, string $wbmpname, int $dest_height, int $dest_width, int $threshold)',
  ),
  'png2wbmp' => 
  array (
    'name' => 'png2wbmp',
    'title' => '将 PNG 图像文件转换为 WBMP 图像文件',
    'ret' => 'bool',
    'prot' => 'bool png2wbmp(string $pngname, string $wbmpname, int $dest_height, int $dest_width, int $threshold)',
  ),
  'assert_options' => 
  array (
    'name' => 'assert_options',
    'title' => '设置/获取断言的各种标志',
    'ret' => 'mixed',
    'prot' => 'mixed assert_options(int $what, mixed $value)',
  ),
  'assert' => 
  array (
    'name' => 'assert',
    'title' => '检查一个断言是否为 &false;',
    'ret' => 'bool',
    'prot' => 'bool assert(mixed $assertion, string $description)',
  ),
  'dl' => 
  array (
    'name' => 'dl',
    'title' => '运行时载入一个 PHP 扩展',
    'ret' => 'bool',
    'prot' => 'bool dl(string $library)',
  ),
  'extension_loaded' => 
  array (
    'name' => 'extension_loaded',
    'title' => '检查一个扩展是否已经加载',
    'ret' => 'bool',
    'prot' => 'bool extension_loaded(string $name)',
  ),
  'gc_collect_cycles' => 
  array (
    'name' => 'gc_collect_cycles',
    'title' => '强制收集所有现存的垃圾循环周期',
    'ret' => 'int',
    'prot' => 'int gc_collect_cycles()',
  ),
  'gc_disable' => 
  array (
    'name' => 'gc_disable',
    'title' => '停用循环引用收集器',
    'ret' => 'void',
    'prot' => 'void gc_disable()',
  ),
  'gc_enable' => 
  array (
    'name' => 'gc_enable',
    'title' => '激活循环引用收集器',
    'ret' => 'void',
    'prot' => 'void gc_enable()',
  ),
  'gc_enabled' => 
  array (
    'name' => 'gc_enabled',
    'title' => '返回循环引用计数器的状态',
    'ret' => 'bool',
    'prot' => 'bool gc_enabled()',
  ),
  'get_cfg_var' => 
  array (
    'name' => 'get_cfg_var',
    'title' => '获取 PHP 配置选项的值',
    'ret' => 'string',
    'prot' => 'string get_cfg_var(string $option)',
  ),
  'get_current_user' => 
  array (
    'name' => 'get_current_user',
    'title' => '获取当前 PHP 脚本所有者名称',
    'ret' => 'string',
    'prot' => 'string get_current_user()',
  ),
  'get_defined_constants' => 
  array (
    'name' => 'get_defined_constants',
    'title' => '返回所有常量的关联数组，键是常量名，值是常量值',
    'ret' => 'array',
    'prot' => 'array get_defined_constants(bool $categorize = false)',
  ),
  'get_extension_funcs' => 
  array (
    'name' => 'get_extension_funcs',
    'title' => '返回模块函数名称的数组',
    'ret' => 'array',
    'prot' => 'array get_extension_funcs(string $module_name)',
  ),
  'get_include_path' => 
  array (
    'name' => 'get_include_path',
    'title' => '获取当前的 include_path 配置选项',
    'ret' => 'string',
    'prot' => 'string get_include_path()',
  ),
  'get_included_files' => 
  array (
    'name' => 'get_included_files',
    'title' => '返回被 include 和 require 文件名的 array',
    'ret' => 'array',
    'prot' => 'array get_included_files()',
  ),
  'get_loaded_extensions' => 
  array (
    'name' => 'get_loaded_extensions',
    'title' => '返回所有编译并加载模块名的 array',
    'ret' => 'array',
    'prot' => 'array get_loaded_extensions(bool $zend_extensions = false)',
  ),
  'get_magic_quotes_gpc' => 
  array (
    'name' => 'get_magic_quotes_gpc',
    'title' => '获取当前 magic_quotes_gpc 的配置选项设置',
    'ret' => 'bool',
    'prot' => 'bool get_magic_quotes_gpc()',
  ),
  'get_magic_quotes_runtime' => 
  array (
    'name' => 'get_magic_quotes_runtime',
    'title' => '获取当前 magic_quotes_runtime 配置选项的激活状态',
    'ret' => 'bool',
    'prot' => 'bool get_magic_quotes_runtime()',
  ),
  'get_required_files' => 
  array (
    'name' => 'get_required_files',
    'title' => '&Alias; get_included_files',
    'ret' => 'bool',
    'prot' => 'bool get_required_files()',
  ),
  'getenv' => 
  array (
    'name' => 'getenv',
    'title' => '获取一个环境变量的值',
    'ret' => 'string',
    'prot' => 'string getenv(string $varname)',
  ),
  'getlastmod' => 
  array (
    'name' => 'getlastmod',
    'title' => '获取页面最后修改的时间',
    'ret' => 'int',
    'prot' => 'int getlastmod()',
  ),
  'getmygid' => 
  array (
    'name' => 'getmygid',
    'title' => '获取当前 PHP 脚本拥有者的 GID',
    'ret' => 'int',
    'prot' => 'int getmygid()',
  ),
  'getmyinode' => 
  array (
    'name' => 'getmyinode',
    'title' => '获取当前脚本的索引节点（inode）',
    'ret' => 'int',
    'prot' => 'int getmyinode()',
  ),
  'getmypid' => 
  array (
    'name' => 'getmypid',
    'title' => '获取 PHP 进程的 ID',
    'ret' => 'int',
    'prot' => 'int getmypid()',
  ),
  'getmyuid' => 
  array (
    'name' => 'getmyuid',
    'title' => '获取 PHP 脚本所有者的 UID',
    'ret' => 'int',
    'prot' => 'int getmyuid()',
  ),
  'getopt' => 
  array (
    'name' => 'getopt',
    'title' => '从命令行参数列表中获取选项',
    'ret' => 'array',
    'prot' => 'array getopt(string $options, array $longopts)',
  ),
  'getrusage' => 
  array (
    'name' => 'getrusage',
    'title' => '获取当前资源使用状况',
    'ret' => 'array',
    'prot' => 'array getrusage(int $who = 0)',
  ),
  'ini_alter' => 
  array (
    'name' => 'ini_alter',
    'title' => '&Alias; ini_set',
    'ret' => 'array',
    'prot' => 'array ini_alter(int $who = 0)',
  ),
  'ini_get_all' => 
  array (
    'name' => 'ini_get_all',
    'title' => '获取所有配置选项',
    'ret' => 'array',
    'prot' => 'array ini_get_all(string $extension, bool $details = true)',
  ),
  'ini_get' => 
  array (
    'name' => 'ini_get',
    'title' => '获取一个配置选项的值',
    'ret' => 'string',
    'prot' => 'string ini_get(string $varname)',
  ),
  'ini_restore' => 
  array (
    'name' => 'ini_restore',
    'title' => '恢复配置选项的值',
    'ret' => 'void',
    'prot' => 'void ini_restore(string $varname)',
  ),
  'ini_set' => 
  array (
    'name' => 'ini_set',
    'title' => '为一个配置选项设置值',
    'ret' => 'string',
    'prot' => 'string ini_set(string $varname, string $newvalue)',
  ),
  'magic_quotes_runtime' => 
  array (
    'name' => 'magic_quotes_runtime',
    'title' => '&Alias; set_magic_quotes_runtime',
    'ret' => 'string',
    'prot' => 'string magic_quotes_runtime(string $varname, string $newvalue)',
  ),
  'main' => 
  array (
    'name' => 'main',
    'title' => '虚拟的main',
    'ret' => 'string',
    'prot' => 'string main(string $varname, string $newvalue)',
  ),
  'memory_get_peak_usage' => 
  array (
    'name' => 'memory_get_peak_usage',
    'title' => '返回分配给 PHP 内存的峰值',
    'ret' => 'int',
    'prot' => 'int memory_get_peak_usage(bool $real_usage = false)',
  ),
  'memory_get_usage' => 
  array (
    'name' => 'memory_get_usage',
    'title' => '返回分配给 PHP 的内存量',
    'ret' => 'int',
    'prot' => 'int memory_get_usage(bool $real_usage = false)',
  ),
  'php_ini_loaded_file' => 
  array (
    'name' => 'php_ini_loaded_file',
    'title' => '取得已加载的 php.ini 文件的路径',
    'ret' => 'string',
    'prot' => 'string php_ini_loaded_file()',
  ),
  'php_ini_scanned_files' => 
  array (
    'name' => 'php_ini_scanned_files',
    'title' => '返回从额外 ini 目录里解析的 .ini 文件列表',
    'ret' => 'string',
    'prot' => 'string php_ini_scanned_files()',
  ),
  'php_logo_guid' => 
  array (
    'name' => 'php_logo_guid',
    'title' => '获取 logo 的 guid',
    'ret' => 'string',
    'prot' => 'string php_logo_guid()',
  ),
  'php_sapi_name' => 
  array (
    'name' => 'php_sapi_name',
    'title' => '返回 web 服务器和 PHP 之间的接口类型',
    'ret' => 'string',
    'prot' => 'string php_sapi_name()',
  ),
  'php_uname' => 
  array (
    'name' => 'php_uname',
    'title' => '返回运行 PHP 的系统的有关信息',
    'ret' => 'string',
    'prot' => 'string php_uname(string $mode = "a")',
  ),
  'phpcredits' => 
  array (
    'name' => 'phpcredits',
    'title' => '打印 PHP 贡献者名单',
    'ret' => 'bool',
    'prot' => 'bool phpcredits(int $flag = CREDITS_ALL)',
  ),
  'phpinfo' => 
  array (
    'name' => 'phpinfo',
    'title' => '输出关于 PHP 配置的信息',
    'ret' => 'bool',
    'prot' => 'bool phpinfo(int $what = INFO_ALL)',
  ),
  'phpversion' => 
  array (
    'name' => 'phpversion',
    'title' => '获取当前的PHP版本',
    'ret' => 'string',
    'prot' => 'string phpversion(string $extension)',
  ),
  'putenv' => 
  array (
    'name' => 'putenv',
    'title' => '设置环境变量的值',
    'ret' => 'bool',
    'prot' => 'bool putenv(string $setting)',
  ),
  'restore_include_path' => 
  array (
    'name' => 'restore_include_path',
    'title' => '还原 include_path 配置选项的值',
    'ret' => 'void',
    'prot' => 'void restore_include_path()',
  ),
  'set_include_path' => 
  array (
    'name' => 'set_include_path',
    'title' => '设置 include_path 配置选项',
    'ret' => 'string',
    'prot' => 'string set_include_path(string $new_include_path)',
  ),
  'set_magic_quotes_runtime' => 
  array (
    'name' => 'set_magic_quotes_runtime',
    'title' => '设置当前 magic_quotes_runtime 配置选项的激活状态',
    'ret' => 'bool',
    'prot' => 'bool set_magic_quotes_runtime(bool $new_setting)',
  ),
  'set_time_limit' => 
  array (
    'name' => 'set_time_limit',
    'title' => '设置脚本最大执行时间',
    'ret' => 'void',
    'prot' => 'void set_time_limit(int $seconds)',
  ),
  'sys_get_temp_dir' => 
  array (
    'name' => 'sys_get_temp_dir',
    'title' => '返回用于临时文件的目录',
    'ret' => 'string',
    'prot' => 'string sys_get_temp_dir()',
  ),
  'version_compare' => 
  array (
    'name' => 'version_compare',
    'title' => '对比两个「PHP 规范化」的版本数字字符串',
    'ret' => 'mixed',
    'prot' => 'mixed version_compare(string $version1, string $version2, string $operator)',
  ),
  'zend_logo_guid' => 
  array (
    'name' => 'zend_logo_guid',
    'title' => '获取 Zend guid',
    'ret' => 'string',
    'prot' => 'string zend_logo_guid()',
  ),
  'zend_thread_id' => 
  array (
    'name' => 'zend_thread_id',
    'title' => '返回当前线程的唯一识别符',
    'ret' => 'int',
    'prot' => 'int zend_thread_id()',
  ),
  'zend_version' => 
  array (
    'name' => 'zend_version',
    'title' => '获取当前 Zend 引擎的版本',
    'ret' => 'string',
    'prot' => 'string zend_version()',
  ),
  'json_decode' => 
  array (
    'name' => 'json_decode',
    'title' => '对 JSON 格式的字符串进行编码',
    'ret' => 'mixed',
    'prot' => 'mixed json_decode(string $json, bool $assoc = false, int $depth = 512, int $options = 0)',
  ),
  'json_encode' => 
  array (
    'name' => 'json_encode',
    'title' => '对变量进行 JSON 编码',
    'ret' => 'string',
    'prot' => 'string json_encode(mixed $value, int $options = 0)',
  ),
  'json_last_error' => 
  array (
    'name' => 'json_last_error',
    'title' => '返回最后发生的错误',
    'ret' => 'int',
    'prot' => 'int json_last_error()',
  ),
  'ezmlm_hash' => 
  array (
    'name' => 'ezmlm_hash',
    'title' => '计算 EZMLM 所需的散列值',
    'ret' => 'int',
    'prot' => 'int ezmlm_hash(string $addr)',
  ),
  'mail' => 
  array (
    'name' => 'mail',
    'title' => '发送邮件',
    'ret' => 'bool',
    'prot' => 'bool mail(string $to, string $subject, string $message, string $additional_headers, string $additional_parameters)',
  ),
  'abs' => 
  array (
    'name' => 'abs',
    'title' => '绝对值',
    'ret' => 'number',
    'prot' => 'number abs(mixed $number)',
  ),
  'acos' => 
  array (
    'name' => 'acos',
    'title' => '反余弦',
    'ret' => 'float',
    'prot' => 'float acos(float $arg)',
  ),
  'acosh' => 
  array (
    'name' => 'acosh',
    'title' => '反双曲余弦',
    'ret' => 'float',
    'prot' => 'float acosh(float $arg)',
  ),
  'asin' => 
  array (
    'name' => 'asin',
    'title' => '反正弦',
    'ret' => 'float',
    'prot' => 'float asin(float $arg)',
  ),
  'asinh' => 
  array (
    'name' => 'asinh',
    'title' => '反双曲正弦',
    'ret' => 'float',
    'prot' => 'float asinh(float $arg)',
  ),
  'atan' => 
  array (
    'name' => 'atan',
    'title' => '反正切',
    'ret' => 'float',
    'prot' => 'float atan(float $arg)',
  ),
  'atan2' => 
  array (
    'name' => 'atan2',
    'title' => '两个参数的反正切',
    'ret' => 'float',
    'prot' => 'float atan2(float $y, float $x)',
  ),
  'atanh' => 
  array (
    'name' => 'atanh',
    'title' => '反双曲正切',
    'ret' => 'float',
    'prot' => 'float atanh(float $arg)',
  ),
  'base_convert' => 
  array (
    'name' => 'base_convert',
    'title' => '在任意进制之间转换数字',
    'ret' => 'string',
    'prot' => 'string base_convert(string $number, int $frombase, int $tobase)',
  ),
  'bindec' => 
  array (
    'name' => 'bindec',
    'title' => '二进制转换为十进制',
    'ret' => 'number',
    'prot' => 'number bindec(string $binary_string)',
  ),
  'ceil' => 
  array (
    'name' => 'ceil',
    'title' => '进一法取整',
    'ret' => 'float',
    'prot' => 'float ceil(float $value)',
  ),
  'cos' => 
  array (
    'name' => 'cos',
    'title' => '余弦',
    'ret' => 'float',
    'prot' => 'float cos(float $arg)',
  ),
  'cosh' => 
  array (
    'name' => 'cosh',
    'title' => '双曲余弦',
    'ret' => 'float',
    'prot' => 'float cosh(float $arg)',
  ),
  'decbin' => 
  array (
    'name' => 'decbin',
    'title' => '十进制转换为二进制',
    'ret' => 'string',
    'prot' => 'string decbin(int $number)',
  ),
  'dechex' => 
  array (
    'name' => 'dechex',
    'title' => '十进制转换为十六进制',
    'ret' => 'string',
    'prot' => 'string dechex(int $number)',
  ),
  'decoct' => 
  array (
    'name' => 'decoct',
    'title' => '十进制转换为八进制',
    'ret' => 'string',
    'prot' => 'string decoct(int $number)',
  ),
  'deg2rad' => 
  array (
    'name' => 'deg2rad',
    'title' => '将角度转换为弧度',
    'ret' => 'float',
    'prot' => 'float deg2rad(float $number)',
  ),
  'exp' => 
  array (
    'name' => 'exp',
    'title' => '计算 e 的指数',
    'ret' => 'float',
    'prot' => 'float exp(float $arg)',
  ),
  'expm1' => 
  array (
    'name' => 'expm1',
    'title' => '返回 exp(number) - 1，甚至当 number 的值接近零也能计算出准确结果',
    'ret' => 'float',
    'prot' => 'float expm1(float $arg)',
  ),
  'floor' => 
  array (
    'name' => 'floor',
    'title' => '舍去法取整',
    'ret' => 'float',
    'prot' => 'float floor(float $value)',
  ),
  'fmod' => 
  array (
    'name' => 'fmod',
    'title' => '返回除法的浮点数余数',
    'ret' => 'float',
    'prot' => 'float fmod(float $x, float $y)',
  ),
  'getrandmax' => 
  array (
    'name' => 'getrandmax',
    'title' => '显示随机数最大的可能值',
    'ret' => 'int',
    'prot' => 'int getrandmax()',
  ),
  'hexdec' => 
  array (
    'name' => 'hexdec',
    'title' => '十六进制转换为十进制',
    'ret' => 'number',
    'prot' => 'number hexdec(string $hex_string)',
  ),
  'hypot' => 
  array (
    'name' => 'hypot',
    'title' => '计算一直角三角形的斜边长度',
    'ret' => 'float',
    'prot' => 'float hypot(float $x, float $y)',
  ),
  'is_finite' => 
  array (
    'name' => 'is_finite',
    'title' => '判断是否为有限值',
    'ret' => 'bool',
    'prot' => 'bool is_finite(float $val)',
  ),
  'is_infinite' => 
  array (
    'name' => 'is_infinite',
    'title' => '判断是否为无限值',
    'ret' => 'bool',
    'prot' => 'bool is_infinite(float $val)',
  ),
  'is_nan' => 
  array (
    'name' => 'is_nan',
    'title' => '判断是否为合法数值',
    'ret' => 'bool',
    'prot' => 'bool is_nan(float $val)',
  ),
  'lcg_value' => 
  array (
    'name' => 'lcg_value',
    'title' => '组合线性同余发生器',
    'ret' => 'float',
    'prot' => 'float lcg_value()',
  ),
  'log' => 
  array (
    'name' => 'log',
    'title' => '自然对数',
    'ret' => 'float',
    'prot' => 'float log(float $arg, float $base = M_E)',
  ),
  'log10' => 
  array (
    'name' => 'log10',
    'title' => '以 10 为底的对数',
    'ret' => 'float',
    'prot' => 'float log10(float $arg)',
  ),
  'log1p' => 
  array (
    'name' => 'log1p',
    'title' => '返回 log(1 + number)，甚至当 number 的值接近零也能计算出准确结果',
    'ret' => 'float',
    'prot' => 'float log1p(float $number)',
  ),
  'max' => 
  array (
    'name' => 'max',
    'title' => '找出最大值',
    'ret' => 'mixed',
    'prot' => 'mixed max(array $values)',
  ),
  'min' => 
  array (
    'name' => 'min',
    'title' => '找出最小值',
    'ret' => 'mixed',
    'prot' => 'mixed min(array $values)',
  ),
  'mt_getrandmax' => 
  array (
    'name' => 'mt_getrandmax',
    'title' => '显示随机数的最大可能值',
    'ret' => 'int',
    'prot' => 'int mt_getrandmax()',
  ),
  'mt_rand' => 
  array (
    'name' => 'mt_rand',
    'title' => '生成更好的随机数',
    'ret' => 'int',
    'prot' => 'int mt_rand()',
  ),
  'mt_srand' => 
  array (
    'name' => 'mt_srand',
    'title' => '播下一个更好的随机数发生器种子',
    'ret' => 'void',
    'prot' => 'void mt_srand(int $seed)',
  ),
  'octdec' => 
  array (
    'name' => 'octdec',
    'title' => '八进制转换为十进制',
    'ret' => 'number',
    'prot' => 'number octdec(string $octal_string)',
  ),
  'pi' => 
  array (
    'name' => 'pi',
    'title' => '得到圆周率值',
    'ret' => 'float',
    'prot' => 'float pi()',
  ),
  'pow' => 
  array (
    'name' => 'pow',
    'title' => '指数表达式',
    'ret' => 'number',
    'prot' => 'number pow(number $base, number $exp)',
  ),
  'rad2deg' => 
  array (
    'name' => 'rad2deg',
    'title' => '将弧度数转换为相应的角度数',
    'ret' => 'float',
    'prot' => 'float rad2deg(float $number)',
  ),
  'rand' => 
  array (
    'name' => 'rand',
    'title' => '产生一个随机整数',
    'ret' => 'int',
    'prot' => 'int rand()',
  ),
  'round' => 
  array (
    'name' => 'round',
    'title' => '对浮点数进行四舍五入',
    'ret' => 'float',
    'prot' => 'float round(float $val, int $precision = 0, int $mode = PHP_ROUND_HALF_UP)',
  ),
  'sin' => 
  array (
    'name' => 'sin',
    'title' => '正弦',
    'ret' => 'float',
    'prot' => 'float sin(float $arg)',
  ),
  'sinh' => 
  array (
    'name' => 'sinh',
    'title' => '双曲正弦',
    'ret' => 'float',
    'prot' => 'float sinh(float $arg)',
  ),
  'sqrt' => 
  array (
    'name' => 'sqrt',
    'title' => '平方根',
    'ret' => 'float',
    'prot' => 'float sqrt(float $arg)',
  ),
  'srand' => 
  array (
    'name' => 'srand',
    'title' => '播下随机数发生器种子',
    'ret' => 'void',
    'prot' => 'void srand(int $seed)',
  ),
  'tan' => 
  array (
    'name' => 'tan',
    'title' => '正切',
    'ret' => 'float',
    'prot' => 'float tan(float $arg)',
  ),
  'tanh' => 
  array (
    'name' => 'tanh',
    'title' => '双曲正切',
    'ret' => 'float',
    'prot' => 'float tanh(float $arg)',
  ),
  'mb_check_encoding' => 
  array (
    'name' => 'mb_check_encoding',
    'title' => '检查字符串在指定的编码里是否有效',
    'ret' => 'bool',
    'prot' => 'bool mb_check_encoding(string $var = &null;, string $encoding = mb_internal_encoding())',
  ),
  'mb_convert_case' => 
  array (
    'name' => 'mb_convert_case',
    'title' => '对字符串进行大小写转换',
    'ret' => 'string',
    'prot' => 'string mb_convert_case(string $str, int $mode = MB_CASE_UPPER, string $encoding = mb_internal_encoding())',
  ),
  'mb_convert_encoding' => 
  array (
    'name' => 'mb_convert_encoding',
    'title' => '转换字符的编码',
    'ret' => 'string',
    'prot' => 'string mb_convert_encoding(string $str, string $to_encoding, mixed $from_encoding)',
  ),
  'mb_convert_variables' => 
  array (
    'name' => 'mb_convert_variables',
    'title' => '转换一个或多个变量的字符编码',
    'ret' => 'string',
    'prot' => 'string mb_convert_variables(string $to_encoding, mixed $from_encoding, mixedvars, mixed...)',
  ),
  'mb_decode_mimeheader' => 
  array (
    'name' => 'mb_decode_mimeheader',
    'title' => '解码 MIME 头字段中的字符串',
    'ret' => 'string',
    'prot' => 'string mb_decode_mimeheader(string $str)',
  ),
  'mb_decode_numericentity' => 
  array (
    'name' => 'mb_decode_numericentity',
    'title' => '根据 HTML 数字字符串解码成字符',
    'ret' => 'string',
    'prot' => 'string mb_decode_numericentity(string $str, array $convmap, string $encoding)',
  ),
  'mb_detect_encoding' => 
  array (
    'name' => 'mb_detect_encoding',
    'title' => '检测字符的编码',
    'ret' => 'string',
    'prot' => 'string mb_detect_encoding(string $str, mixed $encoding_list = mb_detect_order(), bool $strict = false)',
  ),
  'mb_detect_order' => 
  array (
    'name' => 'mb_detect_order',
    'title' => '设置/获取 字符编码的检测顺序',
    'ret' => 'mixed',
    'prot' => 'mixed mb_detect_order(mixed $encoding_list)',
  ),
  'mb_encode_mimeheader' => 
  array (
    'name' => 'mb_encode_mimeheader',
    'title' => '为 MIME 头编码字符串',
    'ret' => 'string',
    'prot' => 'string mb_encode_mimeheader(string $str, string $charset, string $transfer_encoding, string $linefeed = &quot;\\r\\n&quot;, int $indent = 0)',
  ),
  'mb_get_info' => 
  array (
    'name' => 'mb_get_info',
    'title' => '获取 mbstring 的内部设置',
    'ret' => 'mixed',
    'prot' => 'mixed mb_get_info(string $type = "all")',
  ),
  'mb_http_input' => 
  array (
    'name' => 'mb_http_input',
    'title' => '检测 HTTP 输入字符编码',
    'ret' => 'mixed',
    'prot' => 'mixed mb_http_input(string $type = "")',
  ),
  'mb_http_output' => 
  array (
    'name' => 'mb_http_output',
    'title' => '设置/获取 HTTP 输出字符编码',
    'ret' => 'mixed',
    'prot' => 'mixed mb_http_output(string $encoding)',
  ),
  'mb_internal_encoding' => 
  array (
    'name' => 'mb_internal_encoding',
    'title' => '设置/获取内部字符编码',
    'ret' => 'mixed',
    'prot' => 'mixed mb_internal_encoding(string $encoding = mb_internal_encoding())',
  ),
  'mb_language' => 
  array (
    'name' => 'mb_language',
    'title' => '设置/获取当前的语言',
    'ret' => 'mixed',
    'prot' => 'mixed mb_language(string $language)',
  ),
  'mb_list_encodings' => 
  array (
    'name' => 'mb_list_encodings',
    'title' => '返回所有支持编码的数组',
    'ret' => 'array',
    'prot' => 'array mb_list_encodings()',
  ),
  'mb_output_handler' => 
  array (
    'name' => 'mb_output_handler',
    'title' => '在输出缓冲中转换字符编码的回调函数',
    'ret' => 'string',
    'prot' => 'string mb_output_handler(string $contents, int $status)',
  ),
  'mb_parse_str' => 
  array (
    'name' => 'mb_parse_str',
    'title' => '解析 GET/POST/COOKIE 数据并设置全局变量',
    'ret' => 'bool',
    'prot' => 'bool mb_parse_str(string $encoded_string, arrayresult)',
  ),
  'mb_preferred_mime_name' => 
  array (
    'name' => 'mb_preferred_mime_name',
    'title' => '获取 MIME 字符串',
    'ret' => 'string',
    'prot' => 'string mb_preferred_mime_name(string $encoding)',
  ),
  'mb_send_mail' => 
  array (
    'name' => 'mb_send_mail',
    'title' => '发送编码过的邮件',
    'ret' => 'bool',
    'prot' => 'bool mb_send_mail(string $to, string $subject, string $message, string $additional_headers = &null;, string $additional_parameter = &null;)',
  ),
  'mb_split' => 
  array (
    'name' => 'mb_split',
    'title' => '使用正则表达式分割多字节字符串',
    'ret' => 'array',
    'prot' => 'array mb_split(string $pattern, string $string, int $limit = -1)',
  ),
  'mb_strcut' => 
  array (
    'name' => 'mb_strcut',
    'title' => '获取字符的一部分',
    'ret' => 'string',
    'prot' => 'string mb_strcut(string $str, int $start, int $length, string $encoding)',
  ),
  'mb_strimwidth' => 
  array (
    'name' => 'mb_strimwidth',
    'title' => '获取按指定宽度截断的字符串',
    'ret' => 'string',
    'prot' => 'string mb_strimwidth(string $str, int $start, int $width, string $trimmarker, string $encoding)',
  ),
  'mb_stripos' => 
  array (
    'name' => 'mb_stripos',
    'title' => '大小写不敏感地查找字符串在另一个字符串中首次出现的位置',
    'ret' => 'int',
    'prot' => 'int mb_stripos(string $haystack, string $needle, int $offset, string $encoding)',
  ),
  'mb_stristr' => 
  array (
    'name' => 'mb_stristr',
    'title' => '大小写不敏感地查找字符串在另一个字符串里的首次出现',
    'ret' => 'string',
    'prot' => 'string mb_stristr(string $haystack, string $needle, bool $before_needle = false, string $encoding)',
  ),
  'mb_strlen' => 
  array (
    'name' => 'mb_strlen',
    'title' => '获取字符串的长度',
    'ret' => 'int',
    'prot' => 'int mb_strlen(string $str, string $encoding)',
  ),
  'mb_strpos' => 
  array (
    'name' => 'mb_strpos',
    'title' => '查找字符串在另一个字符串中首次出现的位置',
    'ret' => 'int',
    'prot' => 'int mb_strpos(string $haystack, string $needle, int $offset = 0, string $encoding)',
  ),
  'mb_strrchr' => 
  array (
    'name' => 'mb_strrchr',
    'title' => '查找指定字符在另一个字符串中最后一次的出现',
    'ret' => 'string',
    'prot' => 'string mb_strrchr(string $haystack, string $needle, bool $part = false, string $encoding)',
  ),
  'mb_strrichr' => 
  array (
    'name' => 'mb_strrichr',
    'title' => '大小写不敏感地查找指定字符在另一个字符串中最后一次的出现',
    'ret' => 'string',
    'prot' => 'string mb_strrichr(string $haystack, string $needle, bool $part = false, string $encoding)',
  ),
  'mb_strripos' => 
  array (
    'name' => 'mb_strripos',
    'title' => '大小写不敏感地在字符串中查找一个字符串最后出现的位置',
    'ret' => 'int',
    'prot' => 'int mb_strripos(string $haystack, string $needle, int $offset = 0, string $encoding)',
  ),
  'mb_strrpos' => 
  array (
    'name' => 'mb_strrpos',
    'title' => '查找字符串在一个字符串中最后出现的位置',
    'ret' => 'int',
    'prot' => 'int mb_strrpos(string $haystack, string $needle, int $offset = 0, string $encoding)',
  ),
  'mb_strstr' => 
  array (
    'name' => 'mb_strstr',
    'title' => '查找字符串在另一个字符串里的首次出现',
    'ret' => 'string',
    'prot' => 'string mb_strstr(string $haystack, string $needle, bool $before_needle = false, string $encoding)',
  ),
  'mb_strtolower' => 
  array (
    'name' => 'mb_strtolower',
    'title' => '使字符串小写',
    'ret' => 'string',
    'prot' => 'string mb_strtolower(string $str, string $encoding = mb_internal_encoding())',
  ),
  'mb_strtoupper' => 
  array (
    'name' => 'mb_strtoupper',
    'title' => '使字符串大写',
    'ret' => 'string',
    'prot' => 'string mb_strtoupper(string $str, string $encoding = mb_internal_encoding())',
  ),
  'mb_strwidth' => 
  array (
    'name' => 'mb_strwidth',
    'title' => '返回字符串的宽度',
    'ret' => 'int',
    'prot' => 'int mb_strwidth(string $str, string $encoding)',
  ),
  'mb_substitute_character' => 
  array (
    'name' => 'mb_substitute_character',
    'title' => '设置/获取替代字符',
    'ret' => 'mixed',
    'prot' => 'mixed mb_substitute_character(mixed $substrchar)',
  ),
  'mb_substr_count' => 
  array (
    'name' => 'mb_substr_count',
    'title' => '统计字符串出现的次数',
    'ret' => 'int',
    'prot' => 'int mb_substr_count(string $haystack, string $needle, string $encoding)',
  ),
  'mb_substr' => 
  array (
    'name' => 'mb_substr',
    'title' => '获取字符串的部分',
    'ret' => 'string',
    'prot' => 'string mb_substr(string $str, int $start, int $length, string $encoding)',
  ),
  'memcache_debug' => 
  array (
    'name' => 'memcache_debug',
    'title' => '转换调试输出的开/关',
    'ret' => 'bool',
    'prot' => 'bool memcache_debug(bool $on_off)',
  ),
  'connection_aborted' => 
  array (
    'name' => 'connection_aborted',
    'title' => '检查客户端是否已经断开',
    'ret' => 'int',
    'prot' => 'int connection_aborted()',
  ),
  'connection_status' => 
  array (
    'name' => 'connection_status',
    'title' => '返回连接的状态位',
    'ret' => 'int',
    'prot' => 'int connection_status()',
  ),
  'connection_timeout' => 
  array (
    'name' => 'connection_timeout',
    'title' => '检查脚本是否已超时',
    'ret' => 'int',
    'prot' => 'int connection_timeout()',
  ),
  'constant' => 
  array (
    'name' => 'constant',
    'title' => '返回一个常量的值',
    'ret' => 'mixed',
    'prot' => 'mixed constant(string $name)',
  ),
  'define' => 
  array (
    'name' => 'define',
    'title' => '定义一个常量',
    'ret' => 'bool',
    'prot' => 'bool define(string $name, mixed $value, bool $case_insensitive = false)',
  ),
  'defined' => 
  array (
    'name' => 'defined',
    'title' => '检查某个名称的常量是否存在',
    'ret' => 'bool',
    'prot' => 'bool defined(string $name)',
  ),
  'die' => 
  array (
    'name' => 'die',
    'title' => '等同于 exit',
    'ret' => 'bool',
    'prot' => 'bool die(string $name)',
  ),
  'eval' => 
  array (
    'name' => 'eval',
    'title' => '把字符串作为PHP代码执行',
    'ret' => 'mixed',
    'prot' => 'mixed eval(string $code_str)',
  ),
  'exit' => 
  array (
    'name' => 'exit',
    'title' => '输出一个消息并且退出当前脚本',
    'ret' => 'void',
    'prot' => 'void exit(string $status)',
  ),
  'get_browser' => 
  array (
    'name' => 'get_browser',
    'title' => '获取浏览器具有的功能',
    'ret' => 'mixed',
    'prot' => 'mixed get_browser(string $user_agent, bool $return_array = false)',
  ),
  '__halt_compiler' => 
  array (
    'name' => '__halt_compiler',
    'title' => '中断编译器的执行',
    'ret' => 'void',
    'prot' => 'void __halt_compiler()',
  ),
  'highlight_file' => 
  array (
    'name' => 'highlight_file',
    'title' => '语法高亮一个文件',
    'ret' => 'mixed',
    'prot' => 'mixed highlight_file(string $filename, bool $return = false)',
  ),
  'highlight_string' => 
  array (
    'name' => 'highlight_string',
    'title' => '字符串的语法高亮',
    'ret' => 'mixed',
    'prot' => 'mixed highlight_string(string $str, bool $return = false)',
  ),
  'ignore_user_abort' => 
  array (
    'name' => 'ignore_user_abort',
    'title' => '设置客户端断开连接时是否中断脚本的执行',
    'ret' => 'int',
    'prot' => 'int ignore_user_abort(string $value)',
  ),
  'php_check_syntax' => 
  array (
    'name' => 'php_check_syntax',
    'title' => '检查PHP的语法（并执行）指定的文件',
    'ret' => 'bool',
    'prot' => 'bool php_check_syntax(string $filename, stringerror_message)',
  ),
  'php_strip_whitespace' => 
  array (
    'name' => 'php_strip_whitespace',
    'title' => '返回删除注释和空格后的PHP源码',
    'ret' => 'string',
    'prot' => 'string php_strip_whitespace(string $filename)',
  ),
  'sleep' => 
  array (
    'name' => 'sleep',
    'title' => '延缓执行',
    'ret' => 'int',
    'prot' => 'int sleep(int $seconds)',
  ),
  'sys_getloadavg' => 
  array (
    'name' => 'sys_getloadavg',
    'title' => '获取系统的负载（load average）',
    'ret' => 'array',
    'prot' => 'array sys_getloadavg()',
  ),
  'time_nanosleep' => 
  array (
    'name' => 'time_nanosleep',
    'title' => '延缓执行若干秒和纳秒',
    'ret' => 'mixed',
    'prot' => 'mixed time_nanosleep(int $seconds, int $nanoseconds)',
  ),
  'time_sleep_until' => 
  array (
    'name' => 'time_sleep_until',
    'title' => '使脚本睡眠到指定的时间为止。',
    'ret' => 'bool',
    'prot' => 'bool time_sleep_until(float $timestamp)',
  ),
  'uniqid' => 
  array (
    'name' => 'uniqid',
    'title' => '生成一个唯一ID',
    'ret' => 'string',
    'prot' => 'string uniqid(string $prefix = "", bool $more_entropy = false)',
  ),
  'usleep' => 
  array (
    'name' => 'usleep',
    'title' => '以指定的微秒数延迟执行',
    'ret' => 'void',
    'prot' => 'void usleep(int $micro_seconds)',
  ),
  'bson_decode' => 
  array (
    'name' => 'bson_decode',
    'title' => '反序列化一个 BSON 对象为 PHP 数组',
    'ret' => 'array',
    'prot' => 'array bson_decode(string $bson)',
  ),
  'bson_encode' => 
  array (
    'name' => 'bson_encode',
    'title' => '序列化一个 PHP 变量为 BSON 字符串',
    'ret' => 'string',
    'prot' => 'string bson_encode(mixed $anything)',
  ),
  'mysql_affected_rows' => 
  array (
    'name' => 'mysql_affected_rows',
    'title' => '取得前一次 MySQL 操作所影响的记录行数',
    'ret' => 'int',
    'prot' => 'int mysql_affected_rows(resource $link_identifier)',
  ),
  'mysql_client_encoding' => 
  array (
    'name' => 'mysql_client_encoding',
    'title' => '返回字符集的名称',
    'ret' => 'string',
    'prot' => 'string mysql_client_encoding(resource $link_identifier)',
  ),
  'mysql_close' => 
  array (
    'name' => 'mysql_close',
    'title' => '关闭 MySQL 连接',
    'ret' => 'bool',
    'prot' => 'bool mysql_close(resource $link_identifier)',
  ),
  'mysql_connect' => 
  array (
    'name' => 'mysql_connect',
    'title' => '打开一个到 MySQL 服务器的连接',
    'ret' => 'resource',
    'prot' => 'resource mysql_connect(string $server, string $username, string $password, bool $new_link, int $client_flags)',
  ),
  'mysql_create_db' => 
  array (
    'name' => 'mysql_create_db',
    'title' => '新建一个 MySQL 数据库',
    'ret' => 'bool',
    'prot' => 'bool mysql_create_db(string $database name, resource $link_identifier)',
  ),
  'mysql_data_seek' => 
  array (
    'name' => 'mysql_data_seek',
    'title' => '移动内部结果的指针',
    'ret' => 'bool',
    'prot' => 'bool mysql_data_seek(resource $result, int $row_number)',
  ),
  'mysql_db_name' => 
  array (
    'name' => 'mysql_db_name',
    'title' => '取得结果数据',
    'ret' => 'string',
    'prot' => 'string mysql_db_name(resource $result, int $row, mixed $field)',
  ),
  'mysql_db_query' => 
  array (
    'name' => 'mysql_db_query',
    'title' => '发送一条 MySQL 查询',
    'ret' => 'resource',
    'prot' => 'resource mysql_db_query(string $database, string $query, resource $
        link_identifier)',
  ),
  'mysql_drop_db' => 
  array (
    'name' => 'mysql_drop_db',
    'title' => '丢弃（删除）一个 MySQL 数据库',
    'ret' => 'bool',
    'prot' => 'bool mysql_drop_db(string $database_name, resource $
        link_identifier)',
  ),
  'mysql_errno' => 
  array (
    'name' => 'mysql_errno',
    'title' => '返回上一个 MySQL 操作中的错误信息的数字编码',
    'ret' => 'int',
    'prot' => 'int mysql_errno(resource $link_identifier)',
  ),
  'mysql_error' => 
  array (
    'name' => 'mysql_error',
    'title' => '返回上一个 MySQL 操作产生的文本错误信息',
    'ret' => 'string',
    'prot' => 'string mysql_error(resource $link_identifier)',
  ),
  'mysql_escape_string' => 
  array (
    'name' => 'mysql_escape_string',
    'title' => '转义一个字符串用于 mysql_query',
    'ret' => 'string',
    'prot' => 'string mysql_escape_string(string $unescaped_string)',
  ),
  'mysql_fetch_array' => 
  array (
    'name' => 'mysql_fetch_array',
    'title' => '从结果集中取得一行作为关联数组，或数字数组，或二者兼有',
    'ret' => 'array',
    'prot' => 'array mysql_fetch_array(resource $result, int $
        result_type)',
  ),
  'mysql_fetch_assoc' => 
  array (
    'name' => 'mysql_fetch_assoc',
    'title' => '从结果集中取得一行作为关联数组',
    'ret' => 'array',
    'prot' => 'array mysql_fetch_assoc(resource $result)',
  ),
  'mysql_fetch_field' => 
  array (
    'name' => 'mysql_fetch_field',
    'title' => '从结果集中取得列信息并作为对象返回',
    'ret' => 'object',
    'prot' => 'object mysql_fetch_field(resource $result, int $field_offset)',
  ),
  'mysql_fetch_lengths' => 
  array (
    'name' => 'mysql_fetch_lengths',
    'title' => '取得结果集中每个输出的长度',
    'ret' => 'array',
    'prot' => 'array mysql_fetch_lengths(resource $result)',
  ),
  'mysql_fetch_object' => 
  array (
    'name' => 'mysql_fetch_object',
    'title' => '从结果集中取得一行作为对象',
    'ret' => 'object',
    'prot' => 'object mysql_fetch_object(resource $result)',
  ),
  'mysql_fetch_row' => 
  array (
    'name' => 'mysql_fetch_row',
    'title' => '从结果集中取得一行作为枚举数组',
    'ret' => 'array',
    'prot' => 'array mysql_fetch_row(resource $result)',
  ),
  'mysql_field_flags' => 
  array (
    'name' => 'mysql_field_flags',
    'title' => '从结果中取得和指定字段关联的标志',
    'ret' => 'string',
    'prot' => 'string mysql_field_flags(resource $result, int $field_offset)',
  ),
  'mysql_field_len' => 
  array (
    'name' => 'mysql_field_len',
    'title' => '返回指定字段的长度',
    'ret' => 'int',
    'prot' => 'int mysql_field_len(resource $result, int $field_offset)',
  ),
  'mysql_field_name' => 
  array (
    'name' => 'mysql_field_name',
    'title' => '取得结果中指定字段的字段名',
    'ret' => 'string',
    'prot' => 'string mysql_field_name(resource $result, int $field_index)',
  ),
  'mysql_field_seek' => 
  array (
    'name' => 'mysql_field_seek',
    'title' => '将结果集中的指针设定为制定的字段偏移量',
    'ret' => 'int',
    'prot' => 'int mysql_field_seek(resource $result, int $field_offset)',
  ),
  'mysql_field_table' => 
  array (
    'name' => 'mysql_field_table',
    'title' => '取得指定字段所在的表名',
    'ret' => 'string',
    'prot' => 'string mysql_field_table(resource $result, int $field_offset)',
  ),
  'mysql_field_type' => 
  array (
    'name' => 'mysql_field_type',
    'title' => '取得结果集中指定字段的类型',
    'ret' => 'string',
    'prot' => 'string mysql_field_type(resource $result, int $field_offset)',
  ),
  'mysql_free_result' => 
  array (
    'name' => 'mysql_free_result',
    'title' => '释放结果内存',
    'ret' => 'bool',
    'prot' => 'bool mysql_free_result(resource $result)',
  ),
  'mysql_get_client_info' => 
  array (
    'name' => 'mysql_get_client_info',
    'title' => '取得 MySQL 客户端信息',
    'ret' => 'string',
    'prot' => 'string mysql_get_client_info()',
  ),
  'mysql_get_host_info' => 
  array (
    'name' => 'mysql_get_host_info',
    'title' => '取得 MySQL 主机信息',
    'ret' => 'string',
    'prot' => 'string mysql_get_host_info(resource $link_identifier)',
  ),
  'mysql_get_proto_info' => 
  array (
    'name' => 'mysql_get_proto_info',
    'title' => '取得 MySQL 协议信息',
    'ret' => 'int',
    'prot' => 'int mysql_get_proto_info(resource $link_identifier)',
  ),
  'mysql_get_server_info' => 
  array (
    'name' => 'mysql_get_server_info',
    'title' => '取得 MySQL 服务器信息',
    'ret' => 'string',
    'prot' => 'string mysql_get_server_info(resource $link_identifier)',
  ),
  'mysql_info' => 
  array (
    'name' => 'mysql_info',
    'title' => '取得最近一条查询的信息',
    'ret' => 'string',
    'prot' => 'string mysql_info(resource $link_identifier)',
  ),
  'mysql_insert_id' => 
  array (
    'name' => 'mysql_insert_id',
    'title' => '取得上一步 INSERT 操作产生的 ID',
    'ret' => 'int',
    'prot' => 'int mysql_insert_id(resource $link_identifier)',
  ),
  'mysql_list_dbs' => 
  array (
    'name' => 'mysql_list_dbs',
    'title' => '列出 MySQL 服务器中所有的数据库',
    'ret' => 'resource',
    'prot' => 'resource mysql_list_dbs(resource $link_identifier)',
  ),
  'mysql_list_fields' => 
  array (
    'name' => 'mysql_list_fields',
    'title' => '列出 MySQL 结果中的字段',
    'ret' => 'resource',
    'prot' => 'resource mysql_list_fields(string $database_name, string $table_name, resource $link_identifier)',
  ),
  'mysql_list_processes' => 
  array (
    'name' => 'mysql_list_processes',
    'title' => '列出 MySQL 进程',
    'ret' => 'resource',
    'prot' => 'resource mysql_list_processes(resource $link_identifier)',
  ),
  'mysql_list_tables' => 
  array (
    'name' => 'mysql_list_tables',
    'title' => '列出 MySQL 数据库中的表',
    'ret' => 'resource',
    'prot' => 'resource mysql_list_tables(string $database, resource $link_identifier)',
  ),
  'mysql_num_fields' => 
  array (
    'name' => 'mysql_num_fields',
    'title' => '取得结果集中字段的数目',
    'ret' => 'int',
    'prot' => 'int mysql_num_fields(resource $result)',
  ),
  'mysql_num_rows' => 
  array (
    'name' => 'mysql_num_rows',
    'title' => '取得结果集中行的数目',
    'ret' => 'int',
    'prot' => 'int mysql_num_rows(resource $result)',
  ),
  'mysql_pconnect' => 
  array (
    'name' => 'mysql_pconnect',
    'title' => '打开一个到 MySQL 服务器的持久连接',
    'ret' => 'resource',
    'prot' => 'resource mysql_pconnect(string $server, string $username, string $password, int $client_flags)',
  ),
  'mysql_ping' => 
  array (
    'name' => 'mysql_ping',
    'title' => 'Ping 一个服务器连接，如果没有连接则重新连接',
    'ret' => 'bool',
    'prot' => 'bool mysql_ping(resource $
       link_identifier)',
  ),
  'mysql_query' => 
  array (
    'name' => 'mysql_query',
    'title' => '发送一条 MySQL 查询',
    'ret' => 'resource',
    'prot' => 'resource mysql_query(string $query, resource $link_identifier)',
  ),
  'mysql_real_escape_string' => 
  array (
    'name' => 'mysql_real_escape_string',
    'title' => '转义 SQL 语句中使用的字符串中的特殊字符，并考虑到连接的当前字符集',
    'ret' => 'string',
    'prot' => 'string mysql_real_escape_string(string $unescaped_string, resource $link_identifier)',
  ),
  'mysql_result' => 
  array (
    'name' => 'mysql_result',
    'title' => '取得结果数据',
    'ret' => 'mixed',
    'prot' => 'mixed mysql_result(resource $result, int $row, mixed $field)',
  ),
  'mysql_select_db' => 
  array (
    'name' => 'mysql_select_db',
    'title' => '选择 MySQL 数据库',
    'ret' => 'bool',
    'prot' => 'bool mysql_select_db(string $database_name, resource $
        link_identifier)',
  ),
  'mysql_set_charset' => 
  array (
    'name' => 'mysql_set_charset',
    'title' => '设置客户端的字符集',
    'ret' => 'bool',
    'prot' => 'bool mysql_set_charset(string $charset, resource $link_identifier = NULL)',
  ),
  'mysql_stat' => 
  array (
    'name' => 'mysql_stat',
    'title' => '取得当前系统状态',
    'ret' => 'string',
    'prot' => 'string mysql_stat(resource $link_identifier)',
  ),
  'mysql_tablename' => 
  array (
    'name' => 'mysql_tablename',
    'title' => '取得表名',
    'ret' => 'string',
    'prot' => 'string mysql_tablename(resource $result, int $i)',
  ),
  'mysql_thread_id' => 
  array (
    'name' => 'mysql_thread_id',
    'title' => '返回当前线程的 ID',
    'ret' => 'int',
    'prot' => 'int mysql_thread_id(resource $link_identifier)',
  ),
  'mysql_unbuffered_query' => 
  array (
    'name' => 'mysql_unbuffered_query',
    'title' => '向 MySQL 发送一条 SQL 查询，并不获取和缓存结果的行',
    'ret' => 'resource',
    'prot' => 'resource mysql_unbuffered_query(string $query, resource $link_identifier)',
  ),
  'mysqli_bind_param' => 
  array (
    'name' => 'mysqli_bind_param',
    'title' => 'mysqli_stmt_bind_param的别名',
    'ret' => 'resource',
    'prot' => 'resource mysqli_bind_param(string $query, resource $link_identifier)',
  ),
  'mysqli_bind_result' => 
  array (
    'name' => 'mysqli_bind_result',
    'title' => 'mysqli_stmt_bind_result的别名',
    'ret' => 'resource',
    'prot' => 'resource mysqli_bind_result(string $query, resource $link_identifier)',
  ),
  'mysqli_client_encoding' => 
  array (
    'name' => 'mysqli_client_encoding',
    'title' => 'mysqli_character_set_name的别名',
    'ret' => 'resource',
    'prot' => 'resource mysqli_client_encoding(string $query, resource $link_identifier)',
  ),
  'mysqli_connect' => 
  array (
    'name' => 'mysqli_connect',
    'title' => '&Alias; mysqli::__construct',
    'ret' => 'resource',
    'prot' => 'resource mysqli_connect(string $query, resource $link_identifier)',
  ),
  'mysqli_disable_rpl_parse' => 
  array (
    'name' => 'mysqli_disable_rpl_parse',
    'title' => '禁用RPL解析',
    'ret' => 'bool',
    'prot' => 'bool mysqli_disable_rpl_parse(mysqli $link)',
  ),
  'mysqli_enable_reads_from_master' => 
  array (
    'name' => 'mysqli_enable_reads_from_master',
    'title' => '开启从主机读取',
    'ret' => 'bool',
    'prot' => 'bool mysqli_enable_reads_from_master(mysqli $link)',
  ),
  'mysqli_enable_rpl_parse' => 
  array (
    'name' => 'mysqli_enable_rpl_parse',
    'title' => '开启RPL解析',
    'ret' => 'bool',
    'prot' => 'bool mysqli_enable_rpl_parse(mysqli $link)',
  ),
  'mysqli_escape_string' => 
  array (
    'name' => 'mysqli_escape_string',
    'title' => '&Alias; mysqli_real_escape_string',
    'ret' => 'bool',
    'prot' => 'bool mysqli_escape_string(mysqli $link)',
  ),
  'mysqli_execute' => 
  array (
    'name' => 'mysqli_execute',
    'title' => 'mysqli_stmt_execute的别名',
    'ret' => 'bool',
    'prot' => 'bool mysqli_execute(mysqli $link)',
  ),
  'mysqli_fetch' => 
  array (
    'name' => 'mysqli_fetch',
    'title' => 'mysqli_stmt_fetch的别名。',
    'ret' => 'bool',
    'prot' => 'bool mysqli_fetch(mysqli $link)',
  ),
  'mysqli_get_cache_stats' => 
  array (
    'name' => 'mysqli_get_cache_stats',
    'title' => '返回客户端Zval缓存统计信息',
    'ret' => 'array',
    'prot' => 'array mysqli_get_cache_stats()',
  ),
  'mysqli_get_metadata' => 
  array (
    'name' => 'mysqli_get_metadata',
    'title' => 'mysqli_stmt_result_metadata的别名',
    'ret' => 'array',
    'prot' => 'array mysqli_get_metadata()',
  ),
  'mysqli_master_query' => 
  array (
    'name' => 'mysqli_master_query',
    'title' => '在主/从机制中强制在主机中执行一个查询',
    'ret' => 'bool',
    'prot' => 'bool mysqli_master_query(mysqli $link, string $query)',
  ),
  'mysqli_param_count' => 
  array (
    'name' => 'mysqli_param_count',
    'title' => 'mysqli_stmt_param_count的别名',
    'ret' => 'bool',
    'prot' => 'bool mysqli_param_count(mysqli $link, string $query)',
  ),
  'mysqli_report' => 
  array (
    'name' => 'mysqli_report',
    'title' => '开启或禁用（Mysql）内部（错误）报告函数',
    'ret' => 'bool',
    'prot' => 'bool mysqli_report(int $flags)',
  ),
  'mysqli_rpl_parse_enabled' => 
  array (
    'name' => 'mysqli_rpl_parse_enabled',
    'title' => '检查是否开启了RPL解析',
    'ret' => 'int',
    'prot' => 'int mysqli_rpl_parse_enabled(mysqli $link)',
  ),
  'mysqli_rpl_probe' => 
  array (
    'name' => 'mysqli_rpl_probe',
    'title' => 'RPL探测',
    'ret' => 'bool',
    'prot' => 'bool mysqli_rpl_probe(mysqli $link)',
  ),
  'mysqli_send_long_data' => 
  array (
    'name' => 'mysqli_send_long_data',
    'title' => 'mysqli_stmt_send_long_data的别名',
    'ret' => 'bool',
    'prot' => 'bool mysqli_send_long_data(mysqli $link)',
  ),
  'mysqli_set_opt' => 
  array (
    'name' => 'mysqli_set_opt',
    'title' => 'mysqli_options的别名',
    'ret' => 'bool',
    'prot' => 'bool mysqli_set_opt(mysqli $link)',
  ),
  'mysqli_slave_query' => 
  array (
    'name' => 'mysqli_slave_query',
    'title' => '在主/从机制中强制在从机上执行一个查询',
    'ret' => 'bool',
    'prot' => 'bool mysqli_slave_query(mysqli $link, string $query)',
  ),
  'oci_bind_by_name' => 
  array (
    'name' => 'oci_bind_by_name',
    'title' => '绑定一个 PHP 变量到一个 Oracle 位置标志符',
    'ret' => 'bool',
    'prot' => 'bool oci_bind_by_name(resource $stmt, string $ph_name, mixedvariable, int $maxlength, int $type)',
  ),
  'oci_cancel' => 
  array (
    'name' => 'oci_cancel',
    'title' => '取消从游标读取数据',
    'ret' => 'bool',
    'prot' => 'bool oci_cancel(resource $stmt)',
  ),
  'oci_close' => 
  array (
    'name' => 'oci_close',
    'title' => '关闭 Oracle 连接',
    'ret' => 'bool',
    'prot' => 'bool oci_close(resource $connection)',
  ),
  'oci_commit' => 
  array (
    'name' => 'oci_commit',
    'title' => '提交未执行的事务处理',
    'ret' => 'bool',
    'prot' => 'bool oci_commit(resource $connection)',
  ),
  'oci_connect' => 
  array (
    'name' => 'oci_connect',
    'title' => '建立一个到 Oracle 服务器的连接',
    'ret' => 'resource',
    'prot' => 'resource oci_connect(string $username, string $password, string $db, string $charset, int $session_mode)',
  ),
  'oci_define_by_name' => 
  array (
    'name' => 'oci_define_by_name',
    'title' => '在 SELECT 中使用 PHP 变量作为定义的步骤',
    'ret' => 'bool',
    'prot' => 'bool oci_define_by_name(resource $statement, string $column_name, mixedvariable, int $type)',
  ),
  'oci_error' => 
  array (
    'name' => 'oci_error',
    'title' => '返回上一个错误',
    'ret' => 'array',
    'prot' => 'array oci_error(resource $source)',
  ),
  'oci_execute' => 
  array (
    'name' => 'oci_execute',
    'title' => '执行一条语句',
    'ret' => 'bool',
    'prot' => 'bool oci_execute(resource $stmt, int $mode)',
  ),
  'oci_fetch_all' => 
  array (
    'name' => 'oci_fetch_all',
    'title' => '获取结果数据的所有行到一个数组',
    'ret' => 'int',
    'prot' => 'int oci_fetch_all(resource $statement, arrayoutput, int $skip, int $maxrows, int $flags)',
  ),
  'oci_fetch' => 
  array (
    'name' => 'oci_fetch',
    'title' => 'Fetches the next row into result-buffer',
    'ret' => 'bool',
    'prot' => 'bool oci_fetch(resource $statement)',
  ),
  'oci_field_is_null' => 
  array (
    'name' => 'oci_field_is_null',
    'title' => '检查字段是否为 &null;',
    'ret' => 'bool',
    'prot' => 'bool oci_field_is_null(resource $statement, mixed $field)',
  ),
  'oci_field_name' => 
  array (
    'name' => 'oci_field_name',
    'title' => '返回字段名',
    'ret' => 'string',
    'prot' => 'string oci_field_name(resource $statement, int $field)',
  ),
  'oci_field_precision' => 
  array (
    'name' => 'oci_field_precision',
    'title' => '返回字段精度',
    'ret' => 'int',
    'prot' => 'int oci_field_precision(resource $statement, int $field)',
  ),
  'oci_field_scale' => 
  array (
    'name' => 'oci_field_scale',
    'title' => '返回字段范围',
    'ret' => 'int',
    'prot' => 'int oci_field_scale(resource $statement, int $field)',
  ),
  'oci_field_size' => 
  array (
    'name' => 'oci_field_size',
    'title' => '返回字段大小',
    'ret' => 'int',
    'prot' => 'int oci_field_size(resource $stmt, mixed $field)',
  ),
  'oci_field_type_raw' => 
  array (
    'name' => 'oci_field_type_raw',
    'title' => '返回字段的原始 Oracle 数据类型',
    'ret' => 'int',
    'prot' => 'int oci_field_type_raw(resource $statement, int $field)',
  ),
  'oci_field_type' => 
  array (
    'name' => 'oci_field_type',
    'title' => '返回字段的数据类型',
    'ret' => 'mixed',
    'prot' => 'mixed oci_field_type(resource $stmt, int $field)',
  ),
  'oci_free_statement' => 
  array (
    'name' => 'oci_free_statement',
    'title' => '释放关联于语句或游标的所有资源',
    'ret' => 'bool',
    'prot' => 'bool oci_free_statement(resource $statement)',
  ),
  'oci_internal_debug' => 
  array (
    'name' => 'oci_internal_debug',
    'title' => '打开或关闭内部调试输出',
    'ret' => 'void',
    'prot' => 'void oci_internal_debug(int $onoff)',
  ),
  'oci_new_collection' => 
  array (
    'name' => 'oci_new_collection',
    'title' => '分配新的 collection 对象',
    'ret' => 'OCI-Collection',
    'prot' => 'OCI-Collection oci_new_collection(resource $connection, string $tdo, string $schema)',
  ),
  'oci_new_connect' => 
  array (
    'name' => 'oci_new_connect',
    'title' => '建定一个到 Oracle 服务器的新连接',
    'ret' => 'resource',
    'prot' => 'resource oci_new_connect(string $username, string $password, string $db, string $charset, int $session_mode)',
  ),
  'oci_new_cursor' => 
  array (
    'name' => 'oci_new_cursor',
    'title' => '分配并返回一个新的游标（语句句柄）',
    'ret' => 'resource',
    'prot' => 'resource oci_new_cursor(resource $connection)',
  ),
  'oci_new_descriptor' => 
  array (
    'name' => 'oci_new_descriptor',
    'title' => '初始化一个新的空 LOB 或 FILE 描述符',
    'ret' => 'OCI-Lob',
    'prot' => 'OCI-Lob oci_new_descriptor(resource $connection, int $type)',
  ),
  'oci_num_fields' => 
  array (
    'name' => 'oci_num_fields',
    'title' => '返回结果列的数目',
    'ret' => 'int',
    'prot' => 'int oci_num_fields(resource $statement)',
  ),
  'oci_num_rows' => 
  array (
    'name' => 'oci_num_rows',
    'title' => '返回语句执行后受影响的行数',
    'ret' => 'int',
    'prot' => 'int oci_num_rows(resource $stmt)',
  ),
  'oci_parse' => 
  array (
    'name' => 'oci_parse',
    'title' => '配置 Oracle 语句预备执行',
    'ret' => 'resource',
    'prot' => 'resource oci_parse(resource $connection, string $query)',
  ),
  'oci_password_change' => 
  array (
    'name' => 'oci_password_change',
    'title' => '修改 Oracle 用户的密码',
    'ret' => 'bool',
    'prot' => 'bool oci_password_change(resource $connection, string $username, string $old_password, string $new_password)',
  ),
  'oci_pconnect' => 
  array (
    'name' => 'oci_pconnect',
    'title' => '使用一个持久连接连到 Oracle 数据库',
    'ret' => 'resource',
    'prot' => 'resource oci_pconnect(string $username, string $password, string $db, string $charset, int $session_mode)',
  ),
  'oci_result' => 
  array (
    'name' => 'oci_result',
    'title' => '返回所取得行中字段的值',
    'ret' => 'mixed',
    'prot' => 'mixed oci_result(resource $statement, mixed $field)',
  ),
  'oci_rollback' => 
  array (
    'name' => 'oci_rollback',
    'title' => '回滚未提交的事务',
    'ret' => 'bool',
    'prot' => 'bool oci_rollback(resource $connection)',
  ),
  'oci_server_version' => 
  array (
    'name' => 'oci_server_version',
    'title' => '返回服务器版本信息',
    'ret' => 'string',
    'prot' => 'string oci_server_version(resource $connection)',
  ),
  'oci_set_prefetch' => 
  array (
    'name' => 'oci_set_prefetch',
    'title' => '设置预提取行数',
    'ret' => 'bool',
    'prot' => 'bool oci_set_prefetch(resource $statement, int $rows)',
  ),
  'oci_statement_type' => 
  array (
    'name' => 'oci_statement_type',
    'title' => '返回 OCI 语句的类型',
    'ret' => 'string',
    'prot' => 'string oci_statement_type(resource $statement)',
  ),
  'flush' => 
  array (
    'name' => 'flush',
    'title' => '刷新输出缓冲',
    'ret' => 'void',
    'prot' => 'void flush()',
  ),
  'ob_clean' => 
  array (
    'name' => 'ob_clean',
    'title' => '清空（擦掉）输出缓冲区',
    'ret' => 'void',
    'prot' => 'void ob_clean()',
  ),
  'ob_end_clean' => 
  array (
    'name' => 'ob_end_clean',
    'title' => '清空（擦除）缓冲区并关闭输出缓冲',
    'ret' => 'bool',
    'prot' => 'bool ob_end_clean()',
  ),
  'ob_end_flush' => 
  array (
    'name' => 'ob_end_flush',
    'title' => '冲刷出（送出）输出缓冲区内容并关闭缓冲',
    'ret' => 'bool',
    'prot' => 'bool ob_end_flush()',
  ),
  'ob_flush' => 
  array (
    'name' => 'ob_flush',
    'title' => '冲刷出（送出）输出缓冲区中的内容',
    'ret' => 'void',
    'prot' => 'void ob_flush()',
  ),
  'ob_get_clean' => 
  array (
    'name' => 'ob_get_clean',
    'title' => '得到当前缓冲区的内容并删除当前输出缓。',
    'ret' => 'string',
    'prot' => 'string ob_get_clean()',
  ),
  'ob_get_contents' => 
  array (
    'name' => 'ob_get_contents',
    'title' => '返回输出缓冲区的内容',
    'ret' => 'string',
    'prot' => 'string ob_get_contents()',
  ),
  'ob_get_flush' => 
  array (
    'name' => 'ob_get_flush',
    'title' => '刷出（送出）缓冲区内容，以字符串形式返回内容，并关闭输出缓冲区。',
    'ret' => 'string',
    'prot' => 'string ob_get_flush()',
  ),
  'ob_get_length' => 
  array (
    'name' => 'ob_get_length',
    'title' => '返回输出缓冲区内容的长度',
    'ret' => 'int',
    'prot' => 'int ob_get_length()',
  ),
  'ob_get_level' => 
  array (
    'name' => 'ob_get_level',
    'title' => '返回输出缓冲机制的嵌套级别',
    'ret' => 'int',
    'prot' => 'int ob_get_level()',
  ),
  'ob_get_status' => 
  array (
    'name' => 'ob_get_status',
    'title' => '得到所有输出缓冲区的状态',
    'ret' => 'array',
    'prot' => 'array ob_get_status(bool  $full_status  = FALSE)',
  ),
  'ob_gzhandler' => 
  array (
    'name' => 'ob_gzhandler',
    'title' => '在ob_start中使用的用来压缩输出缓冲区中内容的回调函数。ob_start callback function to gzip output buffer',
    'ret' => 'string',
    'prot' => 'string ob_gzhandler(string $buffer, int $mode)',
  ),
  'ob_implicit_flush' => 
  array (
    'name' => 'ob_implicit_flush',
    'title' => '打开/关闭绝对刷送',
    'ret' => 'void',
    'prot' => 'void ob_implicit_flush(int $flag = true)',
  ),
  'ob_list_handlers' => 
  array (
    'name' => 'ob_list_handlers',
    'title' => '列出所有使用中的输出处理程序。',
    'ret' => 'array',
    'prot' => 'array ob_list_handlers()',
  ),
  'ob_start' => 
  array (
    'name' => 'ob_start',
    'title' => '打开输出控制缓冲',
    'ret' => 'bool',
    'prot' => 'bool ob_start(callback $output_callback, int $chunk_size, bool $erase)',
  ),
  'output_add_rewrite_var' => 
  array (
    'name' => 'output_add_rewrite_var',
    'title' => '添加URL重写器的值（Add URL rewriter values）',
    'ret' => 'bool',
    'prot' => 'bool output_add_rewrite_var(string $name, string $value)',
  ),
  'output_reset_rewrite_vars' => 
  array (
    'name' => 'output_reset_rewrite_vars',
    'title' => '重设URL重写器的值（Reset URL rewriter values）',
    'ret' => 'bool',
    'prot' => 'bool output_reset_rewrite_vars()',
  ),
  'pcntl_alarm' => 
  array (
    'name' => 'pcntl_alarm',
    'title' => '为进程设置一个alarm闹钟信号',
    'ret' => 'int',
    'prot' => 'int pcntl_alarm(int $seconds)',
  ),
  'pcntl_exec' => 
  array (
    'name' => 'pcntl_exec',
    'title' => '在当前进程空间执行指定程序',
    'ret' => 'void',
    'prot' => 'void pcntl_exec(string $path, array $args, array $envs)',
  ),
  'pcntl_fork' => 
  array (
    'name' => 'pcntl_fork',
    'title' => '在当前进程当前位置产生分支（子进程）。译注：fork是创建了一个子进程，父进程和子进程
  都从fork的位置开始向下继续执行，不同的是父进程执行过程中，得到的fork返回值为子进程
  号，而子进程得到的是0。',
    'ret' => 'int',
    'prot' => 'int pcntl_fork()',
  ),
  'pcntl_getpriority' => 
  array (
    'name' => 'pcntl_getpriority',
    'title' => '获取任意进程的优先级',
    'ret' => 'int',
    'prot' => 'int pcntl_getpriority(int $pid = getmypid(), int $process_identifier = PRIO_PROCESS)',
  ),
  'pcntl_setpriority' => 
  array (
    'name' => 'pcntl_setpriority',
    'title' => '修改任意进程的优先级',
    'ret' => 'bool',
    'prot' => 'bool pcntl_setpriority(int $priority, int $pid = getmypid(), int $process_identifier = PRIO_PROCESS)',
  ),
  'pcntl_signal_dispatch' => 
  array (
    'name' => 'pcntl_signal_dispatch',
    'title' => '调用等待信号的处理器',
    'ret' => 'bool',
    'prot' => 'bool pcntl_signal_dispatch()',
  ),
  'pcntl_signal' => 
  array (
    'name' => 'pcntl_signal',
    'title' => '安装一个信号处理器',
    'ret' => 'bool',
    'prot' => 'bool pcntl_signal(int $signo, callback $handler, bool $restart_syscalls = true)',
  ),
  'pcntl_sigprocmask' => 
  array (
    'name' => 'pcntl_sigprocmask',
    'title' => '设置或检索阻塞信号',
    'ret' => 'bool',
    'prot' => 'bool pcntl_sigprocmask(int $how, array $set, arrayoldset)',
  ),
  'pcntl_sigtimedwait' => 
  array (
    'name' => 'pcntl_sigtimedwait',
    'title' => '带超时机制的信号等待',
    'ret' => 'int',
    'prot' => 'int pcntl_sigtimedwait(array $set, arraysiginfo, int $seconds = 0, int $nanoseconds = 0)',
  ),
  'pcntl_sigwaitinfo' => 
  array (
    'name' => 'pcntl_sigwaitinfo',
    'title' => '等待信号',
    'ret' => 'int',
    'prot' => 'int pcntl_sigwaitinfo(array $set, arraysiginfo)',
  ),
  'pcntl_wait' => 
  array (
    'name' => 'pcntl_wait',
    'title' => '等待或返回fork的子进程状态',
    'ret' => 'int',
    'prot' => 'int pcntl_wait(intstatus, int $options = 0)',
  ),
  'pcntl_waitpid' => 
  array (
    'name' => 'pcntl_waitpid',
    'title' => '等待或返回fork的子进程状态',
    'ret' => 'int',
    'prot' => 'int pcntl_waitpid(int $pid, intstatus, int $options = 0)',
  ),
  'pcntl_wexitstatus' => 
  array (
    'name' => 'pcntl_wexitstatus',
    'title' => '返回一个中断的子进程的返回代码',
    'ret' => 'int',
    'prot' => 'int pcntl_wexitstatus(int $status)',
  ),
  'pcntl_wifexited' => 
  array (
    'name' => 'pcntl_wifexited',
    'title' => '检查状态代码是否代表一个正常的退出。',
    'ret' => 'bool',
    'prot' => 'bool pcntl_wifexited(int $status)',
  ),
  'pcntl_wifsignaled' => 
  array (
    'name' => 'pcntl_wifsignaled',
    'title' => '检查子进程状态码是否代表由于某个信号而中断',
    'ret' => 'bool',
    'prot' => 'bool pcntl_wifsignaled(int $status)',
  ),
  'pcntl_wifstopped' => 
  array (
    'name' => 'pcntl_wifstopped',
    'title' => '检查子进程当前是否已经停止',
    'ret' => 'bool',
    'prot' => 'bool pcntl_wifstopped(int $status)',
  ),
  'pcntl_wstopsig' => 
  array (
    'name' => 'pcntl_wstopsig',
    'title' => '返回导致子进程停止的信号',
    'ret' => 'int',
    'prot' => 'int pcntl_wstopsig(int $status)',
  ),
  'pcntl_wtermsig' => 
  array (
    'name' => 'pcntl_wtermsig',
    'title' => '返回导致子进程中断的信号',
    'ret' => 'int',
    'prot' => 'int pcntl_wtermsig(int $status)',
  ),
  'preg_filter' => 
  array (
    'name' => 'preg_filter',
    'title' => '执行一个正则表达式搜索和替换',
    'ret' => 'mixed',
    'prot' => 'mixed preg_filter(mixed $pattern, mixed $replacement, mixed $subject, int $limit = -1, intcount)',
  ),
  'preg_grep' => 
  array (
    'name' => 'preg_grep',
    'title' => '返回匹配模式的数组条目',
    'ret' => 'array',
    'prot' => 'array preg_grep(string $pattern, array $input, int $flags = 0)',
  ),
  'preg_last_error' => 
  array (
    'name' => 'preg_last_error',
    'title' => '返回最后一个PCRE正则执行产生的错误代码',
    'ret' => 'int',
    'prot' => 'int preg_last_error()',
  ),
  'preg_match_all' => 
  array (
    'name' => 'preg_match_all',
    'title' => '执行一个全局正则表达式匹配',
    'ret' => 'int',
    'prot' => 'int preg_match_all(string $pattern, string $subject, arraymatches, int $flags = PREG_PATTERN_ORDER, int $offset = 0)',
  ),
  'preg_match' => 
  array (
    'name' => 'preg_match',
    'title' => '执行一个正则表达式匹配',
    'ret' => 'int',
    'prot' => 'int preg_match(string $pattern, string $subject, arraymatches, int $flags = 0, int $offset = 0)',
  ),
  'preg_quote' => 
  array (
    'name' => 'preg_quote',
    'title' => '转义正则表达式字符',
    'ret' => 'string',
    'prot' => 'string preg_quote(string $str, string $delimiter = &null;)',
  ),
  'preg_replace_callback' => 
  array (
    'name' => 'preg_replace_callback',
    'title' => '执行一个正则表达式搜索并且使用一个回调进行替换',
    'ret' => 'mixed',
    'prot' => 'mixed preg_replace_callback(mixed $pattern, callable $callback, mixed $subject, int $limit = -1, intcount)',
  ),
  'preg_replace' => 
  array (
    'name' => 'preg_replace',
    'title' => '执行一个正则表达式的搜索和替换',
    'ret' => 'mixed',
    'prot' => 'mixed preg_replace(mixed $pattern, mixed $replacement, mixed $subject, int $limit = -1, intcount)',
  ),
  'preg_split' => 
  array (
    'name' => 'preg_split',
    'title' => '通过一个正则表达式分隔字符串',
    'ret' => 'array',
    'prot' => 'array preg_split(string $pattern, string $subject, int $limit = -1, int $flags = 0)',
  ),
  'pg_affected_rows' => 
  array (
    'name' => 'pg_affected_rows',
    'title' => '返回受影响的记录数目',
    'ret' => 'int',
    'prot' => 'int pg_affected_rows(resource $result)',
  ),
  'pg_cancel_query' => 
  array (
    'name' => 'pg_cancel_query',
    'title' => '取消异步查询',
    'ret' => 'bool',
    'prot' => 'bool pg_cancel_query(resource $connection)',
  ),
  'pg_client_encoding' => 
  array (
    'name' => 'pg_client_encoding',
    'title' => '取得客户端编码方式',
    'ret' => 'string',
    'prot' => 'string pg_client_encoding(resource $connection)',
  ),
  'pg_close' => 
  array (
    'name' => 'pg_close',
    'title' => '关闭一个 PostgreSQL 连接',
    'ret' => 'bool',
    'prot' => 'bool pg_close(resource $connection)',
  ),
  'pg_connect' => 
  array (
    'name' => 'pg_connect',
    'title' => '打开一个 PostgreSQL 连接',
    'ret' => 'resource',
    'prot' => 'resource pg_connect(string $connection_string)',
  ),
  'pg_connection_busy' => 
  array (
    'name' => 'pg_connection_busy',
    'title' => '获知连接是否为忙',
    'ret' => 'bool',
    'prot' => 'bool pg_connection_busy(resource $connection)',
  ),
  'pg_connection_reset' => 
  array (
    'name' => 'pg_connection_reset',
    'title' => '重置连接（再次连接）',
    'ret' => 'bool',
    'prot' => 'bool pg_connection_reset(resource $connection)',
  ),
  'pg_connection_status' => 
  array (
    'name' => 'pg_connection_status',
    'title' => '获得连接状态',
    'ret' => 'int',
    'prot' => 'int pg_connection_status(resource $connection)',
  ),
  'pg_convert' => 
  array (
    'name' => 'pg_convert',
    'title' => '将关联的数组值转换为适合 SQL 语句的格式。',
    'ret' => 'array',
    'prot' => 'array pg_convert(resource $connection, string $table_name, array $assoc_array, int $options = 0)',
  ),
  'pg_copy_from' => 
  array (
    'name' => 'pg_copy_from',
    'title' => '根据数组将记录插入表中',
    'ret' => 'bool',
    'prot' => 'bool pg_copy_from(resource $connection, string $table_name, array $rows, string $delimiter, string $null_as)',
  ),
  'pg_copy_to' => 
  array (
    'name' => 'pg_copy_to',
    'title' => '将一个表拷贝到数组中',
    'ret' => 'array',
    'prot' => 'array pg_copy_to(resource $connection, string $table_name, string $delimiter, string $null_as)',
  ),
  'pg_dbname' => 
  array (
    'name' => 'pg_dbname',
    'title' => '获得数据库名',
    'ret' => 'string',
    'prot' => 'string pg_dbname(resource $connection)',
  ),
  'pg_delete' => 
  array (
    'name' => 'pg_delete',
    'title' => '删除记录',
    'ret' => 'mixed',
    'prot' => 'mixed pg_delete(resource $connection, string $table_name, array $assoc_array, int $options = PGSQL_DML_EXEC)',
  ),
  'pg_end_copy' => 
  array (
    'name' => 'pg_end_copy',
    'title' => '与 PostgreSQL 后端同步',
    'ret' => 'bool',
    'prot' => 'bool pg_end_copy(resource $connection)',
  ),
  'pg_escape_bytea' => 
  array (
    'name' => 'pg_escape_bytea',
    'title' => '转义 bytea 类型的二进制数据',
    'ret' => 'string',
    'prot' => 'string pg_escape_bytea(string $data)',
  ),
  'pg_escape_string' => 
  array (
    'name' => 'pg_escape_string',
    'title' => '转义 text/char 类型的字符串',
    'ret' => 'string',
    'prot' => 'string pg_escape_string(string $data)',
  ),
  'pg_fetch_all' => 
  array (
    'name' => 'pg_fetch_all',
    'title' => '从结果中提取所有行作为一个数组',
    'ret' => 'array',
    'prot' => 'array pg_fetch_all(resource $result)',
  ),
  'pg_fetch_array' => 
  array (
    'name' => 'pg_fetch_array',
    'title' => '提取一行作为数组',
    'ret' => 'array',
    'prot' => 'array pg_fetch_array(resource $result, int $row, int $result_type)',
  ),
  'pg_fetch_assoc' => 
  array (
    'name' => 'pg_fetch_assoc',
    'title' => '提取一行作为关联数组',
    'ret' => 'array',
    'prot' => 'array pg_fetch_assoc(resource $result, int $row)',
  ),
  'pg_fetch_object' => 
  array (
    'name' => 'pg_fetch_object',
    'title' => '提取一行作为对象',
    'ret' => 'object',
    'prot' => 'object pg_fetch_object(resource $result, int $row, int $result_type)',
  ),
  'pg_fetch_result' => 
  array (
    'name' => 'pg_fetch_result',
    'title' => '从结果资源中返回值',
    'ret' => 'mixed',
    'prot' => 'mixed pg_fetch_result(resource $result, int $row, mixed $field)',
  ),
  'pg_fetch_row' => 
  array (
    'name' => 'pg_fetch_row',
    'title' => '提取一行作为枚举数组',
    'ret' => 'array',
    'prot' => 'array pg_fetch_row(resource $result, int $row, int $result_type)',
  ),
  'pg_field_is_null' => 
  array (
    'name' => 'pg_field_is_null',
    'title' => '测试字段是否为 &null;',
    'ret' => 'int',
    'prot' => 'int pg_field_is_null(resource $result, int $row, mixed $field)',
  ),
  'pg_field_name' => 
  array (
    'name' => 'pg_field_name',
    'title' => '返回字段的名字',
    'ret' => 'string',
    'prot' => 'string pg_field_name(resource $result, int $field_number)',
  ),
  'pg_field_num' => 
  array (
    'name' => 'pg_field_num',
    'title' => '返回字段的编号',
    'ret' => 'int',
    'prot' => 'int pg_field_num(resource $result, string $field_name)',
  ),
  'pg_field_prtlen' => 
  array (
    'name' => 'pg_field_prtlen',
    'title' => '返回打印出来的长度',
    'ret' => 'int',
    'prot' => 'int pg_field_prtlen(resource $result, int $row_number, string $field_name)',
  ),
  'pg_field_size' => 
  array (
    'name' => 'pg_field_size',
    'title' => '返回指定字段占用内部存储空间的大小',
    'ret' => 'int',
    'prot' => 'int pg_field_size(resource $result, int $field_number)',
  ),
  'pg_field_type' => 
  array (
    'name' => 'pg_field_type',
    'title' => '返回相应字段的类型名称',
    'ret' => 'string',
    'prot' => 'string pg_field_type(resource $result, int $field_number)',
  ),
  'pg_free_result' => 
  array (
    'name' => 'pg_free_result',
    'title' => '释放查询结果占用的内存',
    'ret' => 'bool',
    'prot' => 'bool pg_free_result(resource $result)',
  ),
  'pg_get_notify' => 
  array (
    'name' => 'pg_get_notify',
    'title' => 'Ping 数据库连接',
    'ret' => 'array',
    'prot' => 'array pg_get_notify(resource $connection, int $result_type)',
  ),
  'pg_get_pid' => 
  array (
    'name' => 'pg_get_pid',
    'title' => 'Ping 数据库连接',
    'ret' => 'int',
    'prot' => 'int pg_get_pid(resource $connection)',
  ),
  'pg_get_result' => 
  array (
    'name' => 'pg_get_result',
    'title' => '取得异步查询结果',
    'ret' => 'resource',
    'prot' => 'resource pg_get_result(resource $connection)',
  ),
  'pg_host' => 
  array (
    'name' => 'pg_host',
    'title' => '返回和某连接关联的主机名',
    'ret' => 'string',
    'prot' => 'string pg_host(resource $connection)',
  ),
  'pg_insert' => 
  array (
    'name' => 'pg_insert',
    'title' => '将数组插入到表中',
    'ret' => 'mixed',
    'prot' => 'mixed pg_insert(resource $connection, string $table_name, array $assoc_array, int $options = PGSQL_DML_EXEC)',
  ),
  'pg_last_error' => 
  array (
    'name' => 'pg_last_error',
    'title' => '得到某连接的最后一条错误信息',
    'ret' => 'string',
    'prot' => 'string pg_last_error(resource $connection)',
  ),
  'pg_last_notice' => 
  array (
    'name' => 'pg_last_notice',
    'title' => '返回 PostgreSQL 服务器最新一条公告信息',
    'ret' => 'string',
    'prot' => 'string pg_last_notice(resource $connection)',
  ),
  'pg_last_oid' => 
  array (
    'name' => 'pg_last_oid',
    'title' => '返回上一个对象的 oid',
    'ret' => 'int',
    'prot' => 'int pg_last_oid(resource $result)',
  ),
  'pg_lo_close' => 
  array (
    'name' => 'pg_lo_close',
    'title' => '关闭一个大型对象',
    'ret' => 'bool',
    'prot' => 'bool pg_lo_close(resource $large_object)',
  ),
  'pg_lo_create' => 
  array (
    'name' => 'pg_lo_create',
    'title' => '新建一个大型对象',
    'ret' => 'int',
    'prot' => 'int pg_lo_create(resource $connection)',
  ),
  'pg_lo_export' => 
  array (
    'name' => 'pg_lo_export',
    'title' => '将大型对象导出到文件',
    'ret' => 'bool',
    'prot' => 'bool pg_lo_export(resource $connection, int $oid, string $pathname)',
  ),
  'pg_lo_import' => 
  array (
    'name' => 'pg_lo_import',
    'title' => '将文件导入为大型对象',
    'ret' => 'int',
    'prot' => 'int pg_lo_import(resource $connection, string $pathname, mixed $object_id)',
  ),
  'pg_lo_open' => 
  array (
    'name' => 'pg_lo_open',
    'title' => '打开一个大型对象',
    'ret' => 'resource',
    'prot' => 'resource pg_lo_open(resource $connection, int $oid, string $mode)',
  ),
  'pg_lo_read_all' => 
  array (
    'name' => 'pg_lo_read_all',
    'title' => '读入整个大型对象并直接发送给浏览器',
    'ret' => 'int',
    'prot' => 'int pg_lo_read_all(resource $large_object)',
  ),
  'pg_lo_read' => 
  array (
    'name' => 'pg_lo_read',
    'title' => '从大型对象中读入数据',
    'ret' => 'string',
    'prot' => 'string pg_lo_read(resource $large_object, int $len)',
  ),
  'pg_lo_seek' => 
  array (
    'name' => 'pg_lo_seek',
    'title' => '移动大型对象中的指针',
    'ret' => 'bool',
    'prot' => 'bool pg_lo_seek(resource $large_object, int $offset, int $whence)',
  ),
  'pg_lo_tell' => 
  array (
    'name' => 'pg_lo_tell',
    'title' => '返回大型对象的当前指针位置',
    'ret' => 'int',
    'prot' => 'int pg_lo_tell(resource $large_object)',
  ),
  'pg_lo_unlink' => 
  array (
    'name' => 'pg_lo_unlink',
    'title' => '删除一个大型对象',
    'ret' => 'bool',
    'prot' => 'bool pg_lo_unlink(resource $connection, int $oid)',
  ),
  'pg_lo_write' => 
  array (
    'name' => 'pg_lo_write',
    'title' => '向大型对象写入数据',
    'ret' => 'int',
    'prot' => 'int pg_lo_write(resource $large_object, string $data)',
  ),
  'pg_meta_data' => 
  array (
    'name' => 'pg_meta_data',
    'title' => '获得表的元数据',
    'ret' => 'array',
    'prot' => 'array pg_meta_data(resource $connection, string $table_name)',
  ),
  'pg_num_fields' => 
  array (
    'name' => 'pg_num_fields',
    'title' => '返回字段的数目',
    'ret' => 'int',
    'prot' => 'int pg_num_fields(resource $result)',
  ),
  'pg_num_rows' => 
  array (
    'name' => 'pg_num_rows',
    'title' => '返回行的数目',
    'ret' => 'int',
    'prot' => 'int pg_num_rows(resource $result)',
  ),
  'pg_options' => 
  array (
    'name' => 'pg_options',
    'title' => '获得和连接有关的选项',
    'ret' => 'string',
    'prot' => 'string pg_options(resource $connection)',
  ),
  'pg_pconnect' => 
  array (
    'name' => 'pg_pconnect',
    'title' => '打开一个持久的 PostgreSQL 连接',
    'ret' => 'resource',
    'prot' => 'resource pg_pconnect(string $connection_string, int $connect_type)',
  ),
  'pg_ping' => 
  array (
    'name' => 'pg_ping',
    'title' => 'Ping 数据库连接',
    'ret' => 'bool',
    'prot' => 'bool pg_ping(resource $connection)',
  ),
  'pg_port' => 
  array (
    'name' => 'pg_port',
    'title' => '返回该连接的端口号',
    'ret' => 'int',
    'prot' => 'int pg_port(resource $connection)',
  ),
  'pg_put_line' => 
  array (
    'name' => 'pg_put_line',
    'title' => '向 PostgreSQL 后端发送以 NULL 结尾的字符串',
    'ret' => 'bool',
    'prot' => 'bool pg_put_line(resource $connection, string $data)',
  ),
  'pg_query' => 
  array (
    'name' => 'pg_query',
    'title' => '执行查询',
    'ret' => 'resource',
    'prot' => 'resource pg_query(resource $connection, string $query)',
  ),
  'pg_result_error' => 
  array (
    'name' => 'pg_result_error',
    'title' => '获得查询结果的错误信息',
    'ret' => 'string',
    'prot' => 'string pg_result_error(resource $result)',
  ),
  'pg_result_seek' => 
  array (
    'name' => 'pg_result_seek',
    'title' => '在结果资源中设定内部行偏移量',
    'ret' => 'array',
    'prot' => 'array pg_result_seek(resource $result, int $offset)',
  ),
  'pg_result_status' => 
  array (
    'name' => 'pg_result_status',
    'title' => '获得查询结果的状态',
    'ret' => 'int',
    'prot' => 'int pg_result_status(resource $result)',
  ),
  'pg_select' => 
  array (
    'name' => 'pg_select',
    'title' => '选择记录',
    'ret' => 'mixed',
    'prot' => 'mixed pg_select(resource $connection, string $table_name, array $assoc_array, int $options = PGSQL_DML_EXEC)',
  ),
  'pg_send_query' => 
  array (
    'name' => 'pg_send_query',
    'title' => '发送异步查询',
    'ret' => 'bool',
    'prot' => 'bool pg_send_query(resource $connection, string $query)',
  ),
  'pg_set_client_encoding' => 
  array (
    'name' => 'pg_set_client_encoding',
    'title' => '设定客户端编码',
    'ret' => 'int',
    'prot' => 'int pg_set_client_encoding(resource $connection, string $encoding)',
  ),
  'pg_trace' => 
  array (
    'name' => 'pg_trace',
    'title' => '启动一个 PostgreSQL 连接的追踪功能',
    'ret' => 'bool',
    'prot' => 'bool pg_trace(string $pathname, string $mode, resource $connection)',
  ),
  'pg_tty' => 
  array (
    'name' => 'pg_tty',
    'title' => '返回该连接的 tty 号',
    'ret' => 'string',
    'prot' => 'string pg_tty(resource $connection)',
  ),
  'pg_unescape_bytea' => 
  array (
    'name' => 'pg_unescape_bytea',
    'title' => '取消 bytea 类型中的字符串转义',
    'ret' => 'string',
    'prot' => 'string pg_unescape_bytea(string $data)',
  ),
  'pg_untrace' => 
  array (
    'name' => 'pg_untrace',
    'title' => '关闭 PostgreSQL 连接的追踪功能',
    'ret' => 'bool',
    'prot' => 'bool pg_untrace(resource $connection)',
  ),
  'pg_update' => 
  array (
    'name' => 'pg_update',
    'title' => '更新表',
    'ret' => 'mixed',
    'prot' => 'mixed pg_update(resource $connection, string $table_name, array $data, array $condition, int $options = PGSQL_DML_EXEC)',
  ),
  'ereg_replace' => 
  array (
    'name' => 'ereg_replace',
    'title' => '正则表达式替换',
    'ret' => 'string',
    'prot' => 'string ereg_replace(string $pattern, string $replacement, string $string)',
  ),
  'ereg' => 
  array (
    'name' => 'ereg',
    'title' => '正则表达式匹配',
    'ret' => 'int',
    'prot' => 'int ereg(string $pattern, string $string, arrayregs)',
  ),
  'eregi_replace' => 
  array (
    'name' => 'eregi_replace',
    'title' => '不区分大小写的正则表达式替换',
    'ret' => 'string',
    'prot' => 'string eregi_replace(string $pattern, string $replacement, string $string)',
  ),
  'eregi' => 
  array (
    'name' => 'eregi',
    'title' => '不区分大小写的正则表达式匹配',
    'ret' => 'int',
    'prot' => 'int eregi(string $pattern, string $string, arrayregs)',
  ),
  'split' => 
  array (
    'name' => 'split',
    'title' => '用正则表达式将字符串分割到数组中',
    'ret' => 'array',
    'prot' => 'array split(string $pattern, string $string, int $limit)',
  ),
  'spliti' => 
  array (
    'name' => 'spliti',
    'title' => '用正则表达式不区分大小写将字符串分割到数组中',
    'ret' => 'array',
    'prot' => 'array spliti(string $pattern, string $string, int $limit = -1)',
  ),
  'sql_regcase' => 
  array (
    'name' => 'sql_regcase',
    'title' => '产生用于不区分大小的匹配的正则表达式',
    'ret' => 'string',
    'prot' => 'string sql_regcase(string $string)',
  ),
  'session_commit' => 
  array (
    'name' => 'session_commit',
    'title' => 'session_write_close 的&Alias;',
    'ret' => 'string',
    'prot' => 'string session_commit(string $string)',
  ),
  'session_encode' => 
  array (
    'name' => 'session_encode',
    'title' => '将当前会话数据编码为一个字符串',
    'ret' => 'string',
    'prot' => 'string session_encode()',
  ),
  'session_is_registered' => 
  array (
    'name' => 'session_is_registered',
    'title' => '检查变量是否在会话中已经注册',
    'ret' => 'bool',
    'prot' => 'bool session_is_registered(string $name)',
  ),
  'snmp_get_quick_print' => 
  array (
    'name' => 'snmp_get_quick_print',
    'title' => '返回 UCD 库中 quick_print 设置的当前值',
    'ret' => 'bool',
    'prot' => 'bool snmp_get_quick_print()',
  ),
  'snmp_set_quick_print' => 
  array (
    'name' => 'snmp_set_quick_print',
    'title' => '设置 UCD SNMP 库中 quick_print 的值',
    'ret' => 'void',
    'prot' => 'void snmp_set_quick_print(bool $quick_print)',
  ),
  'snmpget' => 
  array (
    'name' => 'snmpget',
    'title' => '获取一个 SNMP 对象',
    'ret' => 'string',
    'prot' => 'string snmpget(string $hostname, string $community, string $object_id, int $timeout, int $retries)',
  ),
  'snmprealwalk' => 
  array (
    'name' => 'snmprealwalk',
    'title' => '返回指定的所有对象，包括它们各自的对象 ID',
    'ret' => 'array',
    'prot' => 'array snmprealwalk(string $host, string $community, string $object_id, int $timeout = 1000000, int $retries = 5)',
  ),
  'snmpset' => 
  array (
    'name' => 'snmpset',
    'title' => '设置一个 SNMP 对象',
    'ret' => 'bool',
    'prot' => 'bool snmpset(string $hostname, string $community, string $object_id, string $type, mixed $value, int $timeout, int $retries)',
  ),
  'snmpwalk' => 
  array (
    'name' => 'snmpwalk',
    'title' => '从代理返回所有的 SNMP 对象',
    'ret' => 'array',
    'prot' => 'array snmpwalk(string $hostname, string $community, string $object_id, int $timeout, int $retries)',
  ),
  'snmpwalkoid' => 
  array (
    'name' => 'snmpwalkoid',
    'title' => '查询关于网络实体的信息树',
    'ret' => 'array',
    'prot' => 'array snmpwalkoid(string $hostname, string $community, string $object_id, int $timeout, int $retries)',
  ),
  'socket_create' => 
  array (
    'name' => 'socket_create',
    'title' => '创建一个套接字（通讯节点）',
    'ret' => 'resource',
    'prot' => 'resource socket_create(int $domain, int $type, int $protocol)',
  ),
  'class_implements' => 
  array (
    'name' => 'class_implements',
    'title' => '返回指定的类实现的所有接口。',
    'ret' => 'array',
    'prot' => 'array class_implements(mixed $class, bool $autoload)',
  ),
  'class_parents' => 
  array (
    'name' => 'class_parents',
    'title' => '返回指定类的父类。',
    'ret' => 'array',
    'prot' => 'array class_parents(mixed $class, bool $autoload)',
  ),
  'iterator_apply' => 
  array (
    'name' => 'iterator_apply',
    'title' => '为迭代器中每个元素调用一个用户自定义函数',
    'ret' => 'int',
    'prot' => 'int iterator_apply(Traversable $iterator, callable $function, array $args)',
  ),
  'iterator_count' => 
  array (
    'name' => 'iterator_count',
    'title' => '计算迭代器中元素的个数',
    'ret' => 'int',
    'prot' => 'int iterator_count(Traversable $iterator)',
  ),
  'iterator_to_array' => 
  array (
    'name' => 'iterator_to_array',
    'title' => '将迭代器中的元素拷贝到数组',
    'ret' => 'array',
    'prot' => 'array iterator_to_array(Traversable $iterator, bool $use_keys = true)',
  ),
  'spl_autoload_call' => 
  array (
    'name' => 'spl_autoload_call',
    'title' => '尝试调用所有已注册的__autoload()函数来装载请求类',
    'ret' => 'void',
    'prot' => 'void spl_autoload_call(string $class_name)',
  ),
  'spl_autoload_extensions' => 
  array (
    'name' => 'spl_autoload_extensions',
    'title' => '注册并返回spl_autoload函数使用的默认文件扩展名。',
    'ret' => 'string',
    'prot' => 'string spl_autoload_extensions(string $file_extensions)',
  ),
  'spl_autoload_functions' => 
  array (
    'name' => 'spl_autoload_functions',
    'title' => '返回所有已注册的__autoload()函数。',
    'ret' => 'array',
    'prot' => 'array spl_autoload_functions()',
  ),
  'spl_autoload_register' => 
  array (
    'name' => 'spl_autoload_register',
    'title' => '注册__autoload()函数',
    'ret' => 'bool',
    'prot' => 'bool spl_autoload_register(callback $autoload_function)',
  ),
  'spl_autoload_unregister' => 
  array (
    'name' => 'spl_autoload_unregister',
    'title' => '注销已注册的__autoload()函数',
    'ret' => 'bool',
    'prot' => 'bool spl_autoload_unregister(mixed $autoload_function)',
  ),
  'spl_autoload' => 
  array (
    'name' => 'spl_autoload',
    'title' => '__autoload()函数的默认实现',
    'ret' => 'void',
    'prot' => 'void spl_autoload(string $class_name, string $file_extensions)',
  ),
  'spl_classes' => 
  array (
    'name' => 'spl_classes',
    'title' => '返回所有可用的SPL类',
    'ret' => 'array',
    'prot' => 'array spl_classes()',
  ),
  'spl_object_hash' => 
  array (
    'name' => 'spl_object_hash',
    'title' => '返回指定对象的hash id',
    'ret' => 'string',
    'prot' => 'string spl_object_hash(object $obj)',
  ),
  'stream_get_meta_data' => 
  array (
    'name' => 'stream_get_meta_data',
    'title' => '从封装协议文件指针中取得报头／元数据',
    'ret' => 'array',
    'prot' => 'array stream_get_meta_data(int $fp)',
  ),
  'stream_register_wrapper' => 
  array (
    'name' => 'stream_register_wrapper',
    'title' => '注册一个用 PHP 类实现的 URL 封装协议',
    'ret' => 'boolean',
    'prot' => 'boolean stream_register_wrapper(string $protocol, string $classname)',
  ),
  'addcslashes' => 
  array (
    'name' => 'addcslashes',
    'title' => '以 C 语言风格使用反斜线转义字符串中的字符',
    'ret' => 'string',
    'prot' => 'string addcslashes(string $str, string $charlist)',
  ),
  'addslashes' => 
  array (
    'name' => 'addslashes',
    'title' => '使用反斜线引用字符串',
    'ret' => 'string',
    'prot' => 'string addslashes(string $str)',
  ),
  'bin2hex' => 
  array (
    'name' => 'bin2hex',
    'title' => '将二进制数据转换成十六进制表示',
    'ret' => 'string',
    'prot' => 'string bin2hex(string $str)',
  ),
  'chop' => 
  array (
    'name' => 'chop',
    'title' => 'rtrim 的&Alias;',
    'ret' => 'string',
    'prot' => 'string chop(string $str)',
  ),
  'chr' => 
  array (
    'name' => 'chr',
    'title' => '返回指定的字符',
    'ret' => 'string',
    'prot' => 'string chr(int $ascii)',
  ),
  'chunk_split' => 
  array (
    'name' => 'chunk_split',
    'title' => '将字符串分割成小块',
    'ret' => 'string',
    'prot' => 'string chunk_split(string $body, int $chunklen = 76, string $end = "\\r\\n")',
  ),
  'convert_cyr_string' => 
  array (
    'name' => 'convert_cyr_string',
    'title' => '将字符由一种 Cyrillic 字符转换成另一种',
    'ret' => 'string',
    'prot' => 'string convert_cyr_string(string $str, string $from, string $to)',
  ),
  'convert_uudecode' => 
  array (
    'name' => 'convert_uudecode',
    'title' => '解码一个 uuencode 编码的字符串',
    'ret' => 'string',
    'prot' => 'string convert_uudecode(string $data)',
  ),
  'convert_uuencode' => 
  array (
    'name' => 'convert_uuencode',
    'title' => '使用 uuencode 编码一个字符串',
    'ret' => 'string',
    'prot' => 'string convert_uuencode(string $data)',
  ),
  'count_chars' => 
  array (
    'name' => 'count_chars',
    'title' => '返回字符串所用字符的信息',
    'ret' => 'mixed',
    'prot' => 'mixed count_chars(string $string, int $mode = 0)',
  ),
  'crc32' => 
  array (
    'name' => 'crc32',
    'title' => '计算一个字符串的 crc32 多项式',
    'ret' => 'int',
    'prot' => 'int crc32(string $str)',
  ),
  'crypt' => 
  array (
    'name' => 'crypt',
    'title' => '单向字符串散列',
    'ret' => 'string',
    'prot' => 'string crypt(string $str, string $salt)',
  ),
  'echo' => 
  array (
    'name' => 'echo',
    'title' => '输出一个或多个字符串',
    'ret' => 'void',
    'prot' => 'void echo(string $arg1, string $...)',
  ),
  'explode' => 
  array (
    'name' => 'explode',
    'title' => '使用一个字符串分割另一个字符串',
    'ret' => 'array',
    'prot' => 'array explode(string $delimiter, string $string, int $limit)',
  ),
  'fprintf' => 
  array (
    'name' => 'fprintf',
    'title' => '将格式化后的字符串写入到流',
    'ret' => 'int',
    'prot' => 'int fprintf(resource $handle, string $format, mixed $args, mixed $...)',
  ),
  'get_html_translation_table' => 
  array (
    'name' => 'get_html_translation_table',
    'title' => '返回使用 htmlspecialchars 和 htmlentities 后的转换表',
    'ret' => 'array',
    'prot' => 'array get_html_translation_table(int $table = HTML_SPECIALCHARS, int $flags = ENT_COMPAT | ENT_HTML401, string $encoding = \'UTF-8\')',
  ),
  'hebrev' => 
  array (
    'name' => 'hebrev',
    'title' => '将逻辑顺序希伯来文（logical-Hebrew）转换为视觉顺序希伯来文（visual-Hebrew）',
    'ret' => 'string',
    'prot' => 'string hebrev(string $hebrew_text, int $max_chars_per_line = 0)',
  ),
  'hebrevc' => 
  array (
    'name' => 'hebrevc',
    'title' => '将逻辑顺序希伯来文（logical-Hebrew）转换为视觉顺序希伯来文（visual-Hebrew），并且转换换行符',
    'ret' => 'string',
    'prot' => 'string hebrevc(string $hebrew_text, int $max_chars_per_line = 0)',
  ),
  'htmlspecialchars_decode' => 
  array (
    'name' => 'htmlspecialchars_decode',
    'title' => '将特殊的 HTML 实体转换回普通字符',
    'ret' => 'string',
    'prot' => 'string htmlspecialchars_decode(string $string, int $flags = ENT_COMPAT | ENT_HTML401)',
  ),
  'lcfirst' => 
  array (
    'name' => 'lcfirst',
    'title' => '使一个字符串的第一个字符小写',
    'ret' => 'string',
    'prot' => 'string lcfirst(string $str)',
  ),
  'levenshtein' => 
  array (
    'name' => 'levenshtein',
    'title' => '计算两个字符串之间的编辑距离',
    'ret' => 'int',
    'prot' => 'int levenshtein(string $str1, string $str2)',
  ),
  'ltrim' => 
  array (
    'name' => 'ltrim',
    'title' => '删除字符串开头的空白字符（或其他字符）',
    'ret' => 'string',
    'prot' => 'string ltrim(string $str, string $charlist)',
  ),
  'md5_file' => 
  array (
    'name' => 'md5_file',
    'title' => '计算指定文件的 MD5 散列值',
    'ret' => 'string',
    'prot' => 'string md5_file(string $filename, bool $raw_output = false)',
  ),
  'md5' => 
  array (
    'name' => 'md5',
    'title' => '计算字符串的 MD5 散列值',
    'ret' => 'string',
    'prot' => 'string md5(string $str, bool $raw_output = false)',
  ),
  'nl2br' => 
  array (
    'name' => 'nl2br',
    'title' => '在字符串所有新行之前插入 HTML 换行标记',
    'ret' => 'string',
    'prot' => 'string nl2br(string $string, bool $is_xhtml = true)',
  ),
  'ord' => 
  array (
    'name' => 'ord',
    'title' => '返回字符的 ASCII 码值',
    'ret' => 'int',
    'prot' => 'int ord(string $string)',
  ),
  'parse_str' => 
  array (
    'name' => 'parse_str',
    'title' => '将字符串解析成多个变量',
    'ret' => 'void',
    'prot' => 'void parse_str(string $str, arrayarr)',
  ),
  'print' => 
  array (
    'name' => 'print',
    'title' => '输出字符串',
    'ret' => 'int',
    'prot' => 'int print(string $arg)',
  ),
  'printf' => 
  array (
    'name' => 'printf',
    'title' => '输出格式化字符串',
    'ret' => 'int',
    'prot' => 'int printf(string $format, mixed $args, mixed $...)',
  ),
  'rtrim' => 
  array (
    'name' => 'rtrim',
    'title' => '删除字符串末端的空白字符（或者其他字符）',
    'ret' => 'string',
    'prot' => 'string rtrim(string $str, string $charlist)',
  ),
  'sha1_file' => 
  array (
    'name' => 'sha1_file',
    'title' => '计算文件的 sha1 散列值',
    'ret' => 'string',
    'prot' => 'string sha1_file(string $filename, bool $raw_output = false)',
  ),
  'sha1' => 
  array (
    'name' => 'sha1',
    'title' => '计算字符串的 sha1 散列值',
    'ret' => 'string',
    'prot' => 'string sha1(string $str, bool $raw_output = false)',
  ),
  'similar_text' => 
  array (
    'name' => 'similar_text',
    'title' => '计算两个字符串的相似度',
    'ret' => 'int',
    'prot' => 'int similar_text(string $first, string $second, floatpercent)',
  ),
  'str_getcsv' => 
  array (
    'name' => 'str_getcsv',
    'title' => '解析 CSV 字符串为一个数组',
    'ret' => 'array',
    'prot' => 'array str_getcsv(string $input, string $delimiter = \',\', string $enclosure = \'"\', string $escape = \'\\\\\')',
  ),
  'str_ireplace' => 
  array (
    'name' => 'str_ireplace',
    'title' => 'str_replace 的忽略大小写版本',
    'ret' => 'mixed',
    'prot' => 'mixed str_ireplace(mixed $search, mixed $replace, mixed $subject, intcount)',
  ),
  'str_pad' => 
  array (
    'name' => 'str_pad',
    'title' => '使用另一个字符串填充字符串为指定长度',
    'ret' => 'string',
    'prot' => 'string str_pad(string $input, int $pad_length, string $pad_string = " ", int $pad_type = STR_PAD_RIGHT)',
  ),
  'str_repeat' => 
  array (
    'name' => 'str_repeat',
    'title' => '重复一个字符串',
    'ret' => 'string',
    'prot' => 'string str_repeat(string $input, int $multiplier)',
  ),
  'str_replace' => 
  array (
    'name' => 'str_replace',
    'title' => '子字符串替换',
    'ret' => 'mixed',
    'prot' => 'mixed str_replace(mixed $search, mixed $replace, mixed $subject, intcount)',
  ),
  'str_rot13' => 
  array (
    'name' => 'str_rot13',
    'title' => '对字符串执行 ROT13 转换',
    'ret' => 'string',
    'prot' => 'string str_rot13(string $str)',
  ),
  'str_shuffle' => 
  array (
    'name' => 'str_shuffle',
    'title' => '随机打乱一个字符串',
    'ret' => 'string',
    'prot' => 'string str_shuffle(string $str)',
  ),
  'str_split' => 
  array (
    'name' => 'str_split',
    'title' => '将字符串转换为数组',
    'ret' => 'array',
    'prot' => 'array str_split(string $string, int $split_length = 1)',
  ),
  'str_word_count' => 
  array (
    'name' => 'str_word_count',
    'title' => '返回字符串中单词的使用情况',
    'ret' => 'mixed',
    'prot' => 'mixed str_word_count(string $string, int $format = 0, string $charlist)',
  ),
  'strcasecmp' => 
  array (
    'name' => 'strcasecmp',
    'title' => '二进制安全比较字符串（不区分大小写）',
    'ret' => 'int',
    'prot' => 'int strcasecmp(string $str1, string $str2)',
  ),
  'strcmp' => 
  array (
    'name' => 'strcmp',
    'title' => '二进制安全字符串比较',
    'ret' => 'int',
    'prot' => 'int strcmp(string $str1, string $str2)',
  ),
  'strcoll' => 
  array (
    'name' => 'strcoll',
    'title' => '基于区域设置的字符串比较',
    'ret' => 'int',
    'prot' => 'int strcoll(string $str1, string $str2)',
  ),
  'strcspn' => 
  array (
    'name' => 'strcspn',
    'title' => '获取不匹配遮罩的起始子字符串的长度',
    'ret' => 'int',
    'prot' => 'int strcspn(string $str1, string $str2, int $start, int $length)',
  ),
  'strip_tags' => 
  array (
    'name' => 'strip_tags',
    'title' => '从字符串中去除 HTML 和 PHP 标记',
    'ret' => 'string',
    'prot' => 'string strip_tags(string $str, string $allowable_tags)',
  ),
  'stripcslashes' => 
  array (
    'name' => 'stripcslashes',
    'title' => '反引用一个使用 addcslashes 转义的字符串',
    'ret' => 'string',
    'prot' => 'string stripcslashes(string $str)',
  ),
  'stripos' => 
  array (
    'name' => 'stripos',
    'title' => '查找字符串首次出现的位置（不区分大小写）',
    'ret' => 'int',
    'prot' => 'int stripos(string $haystack, string $needle, int $offset = 0)',
  ),
  'stripslashes' => 
  array (
    'name' => 'stripslashes',
    'title' => '反引用一个引用字符串',
    'ret' => 'string',
    'prot' => 'string stripslashes(string $str)',
  ),
  'stristr' => 
  array (
    'name' => 'stristr',
    'title' => 'strstr 函数的忽略大小写版本',
    'ret' => 'string',
    'prot' => 'string stristr(string $haystack, mixed $needle, bool $before_needle = false)',
  ),
  'strlen' => 
  array (
    'name' => 'strlen',
    'title' => '获取字符串长度',
    'ret' => 'int',
    'prot' => 'int strlen(string $string)',
  ),
  'strnatcasecmp' => 
  array (
    'name' => 'strnatcasecmp',
    'title' => '使用“自然顺序”算法比较字符串（不区分大小写）',
    'ret' => 'int',
    'prot' => 'int strnatcasecmp(string $str1, string $str2)',
  ),
  'strnatcmp' => 
  array (
    'name' => 'strnatcmp',
    'title' => '使用自然排序算法比较字符串',
    'ret' => 'int',
    'prot' => 'int strnatcmp(string $str1, string $str2)',
  ),
  'strncasecmp' => 
  array (
    'name' => 'strncasecmp',
    'title' => '二进制安全比较字符串开头的若干个字符（不区分大小写）',
    'ret' => 'int',
    'prot' => 'int strncasecmp(string $str1, string $str2, int $len)',
  ),
  'strncmp' => 
  array (
    'name' => 'strncmp',
    'title' => '二进制安全比较字符串开头的若干个字符',
    'ret' => 'int',
    'prot' => 'int strncmp(string $str1, string $str2, int $len)',
  ),
  'strpbrk' => 
  array (
    'name' => 'strpbrk',
    'title' => '在字符串中查找一组字符的任何一个字符',
    'ret' => 'string',
    'prot' => 'string strpbrk(string $haystack, string $char_list)',
  ),
  'strpos' => 
  array (
    'name' => 'strpos',
    'title' => '查找字符串首次出现的位置',
    'ret' => 'int',
    'prot' => 'int strpos(string $haystack, mixed $needle, int $offset = 0)',
  ),
  'strrchr' => 
  array (
    'name' => 'strrchr',
    'title' => '查找指定字符在字符串中的最后一次出现',
    'ret' => 'string',
    'prot' => 'string strrchr(string $haystack, mixed $needle)',
  ),
  'strrev' => 
  array (
    'name' => 'strrev',
    'title' => '反转字符串',
    'ret' => 'string',
    'prot' => 'string strrev(string $string)',
  ),
  'strripos' => 
  array (
    'name' => 'strripos',
    'title' => '计算指定字符串在目标字符串中最后一次出现的位置（不区分大小写）',
    'ret' => 'int',
    'prot' => 'int strripos(string $haystack, string $needle, int $offset = 0)',
  ),
  'strrpos' => 
  array (
    'name' => 'strrpos',
    'title' => '计算指定字符串在目标字符串中最后一次出现的位置',
    'ret' => 'int',
    'prot' => 'int strrpos(string $haystack, string $needle, int $offset = 0)',
  ),
  'strspn' => 
  array (
    'name' => 'strspn',
    'title' => '计算字符串中全部字符都存在于指定字符集合中的第一段子串的长度。',
    'ret' => 'int',
    'prot' => 'int strspn(string $subject, string $mask, int $start, int $length)',
  ),
  'strstr' => 
  array (
    'name' => 'strstr',
    'title' => '查找字符串的首次出现',
    'ret' => 'string',
    'prot' => 'string strstr(string $haystack, mixed $needle, bool $before_needle = false)',
  ),
  'strtok' => 
  array (
    'name' => 'strtok',
    'title' => '标记分割字符串',
    'ret' => 'string',
    'prot' => 'string strtok(string $str, string $token)',
  ),
  'strtolower' => 
  array (
    'name' => 'strtolower',
    'title' => '将字符串转化为小写',
    'ret' => 'string',
    'prot' => 'string strtolower(string $str)',
  ),
  'strtoupper' => 
  array (
    'name' => 'strtoupper',
    'title' => '将字符串转化为大写',
    'ret' => 'string',
    'prot' => 'string strtoupper(string $string)',
  ),
  'strtr' => 
  array (
    'name' => 'strtr',
    'title' => '转换指定字符',
    'ret' => 'string',
    'prot' => 'string strtr(string $str, string $from, string $to)',
  ),
  'substr_compare' => 
  array (
    'name' => 'substr_compare',
    'title' => '二进制安全比较字符串（从偏移位置比较指定长度）',
    'ret' => 'int',
    'prot' => 'int substr_compare(string $main_str, string $str, int $offset, int $length, bool $case_insensitivity = false)',
  ),
  'substr_count' => 
  array (
    'name' => 'substr_count',
    'title' => '计算字串出现的次数',
    'ret' => 'int',
    'prot' => 'int substr_count(string $haystack, string $needle, int $offset = 0, int $length)',
  ),
  'substr_replace' => 
  array (
    'name' => 'substr_replace',
    'title' => '替换字符串的子串',
    'ret' => 'mixed',
    'prot' => 'mixed substr_replace(mixed $string, mixed $replacement, mixed $start, mixed $length)',
  ),
  'substr' => 
  array (
    'name' => 'substr',
    'title' => '返回字符串的子串',
    'ret' => 'string',
    'prot' => 'string substr(string $string, int $start, int $length)',
  ),
  'trim' => 
  array (
    'name' => 'trim',
    'title' => '去除字符串首尾处的空白字符（或者其他字符）',
    'ret' => 'string',
    'prot' => 'string trim(string $str, string $charlist)',
  ),
  'ucfirst' => 
  array (
    'name' => 'ucfirst',
    'title' => '将字符串的首字母转换为大写',
    'ret' => 'string',
    'prot' => 'string ucfirst(string $str)',
  ),
  'ucwords' => 
  array (
    'name' => 'ucwords',
    'title' => '将字符串中每个单词的首字母转换为大写',
    'ret' => 'string',
    'prot' => 'string ucwords(string $str)',
  ),
  'vfprintf' => 
  array (
    'name' => 'vfprintf',
    'title' => '将格式化字符串写入流',
    'ret' => 'int',
    'prot' => 'int vfprintf(resource $handle, string $format, array $args)',
  ),
  'vprintf' => 
  array (
    'name' => 'vprintf',
    'title' => '输出格式化字符串',
    'ret' => 'int',
    'prot' => 'int vprintf(string $format, array $args)',
  ),
  'vsprintf' => 
  array (
    'name' => 'vsprintf',
    'title' => '返回格式化字符串',
    'ret' => 'string',
    'prot' => 'string vsprintf(string $format, array $args)',
  ),
  'wordwrap' => 
  array (
    'name' => 'wordwrap',
    'title' => '打断字符串为指定数量的字串',
    'ret' => 'string',
    'prot' => 'string wordwrap(string $str, int $width = 75, string $break = "\\n", bool $cut = false)',
  ),
  'base64_decode' => 
  array (
    'name' => 'base64_decode',
    'title' => '对使用 MIME base64 编码的数据进行解码',
    'ret' => 'string',
    'prot' => 'string base64_decode(string $data, bool $strict = false)',
  ),
  'base64_encode' => 
  array (
    'name' => 'base64_encode',
    'title' => '使用 MIME base64 对数据进行编码',
    'ret' => 'string',
    'prot' => 'string base64_encode(string $data)',
  ),
  'get_headers' => 
  array (
    'name' => 'get_headers',
    'title' => '取得服务器响应一个 HTTP 请求所发送的所有标头',
    'ret' => 'array',
    'prot' => 'array get_headers(string $url, int $format = 0)',
  ),
  'get_meta_tags' => 
  array (
    'name' => 'get_meta_tags',
    'title' => '从一个文件中提取所有的 meta 标签 content 属性，返回一个数组',
    'ret' => 'array',
    'prot' => 'array get_meta_tags(string $filename, bool $use_include_path = false)',
  ),
  'http_build_query' => 
  array (
    'name' => 'http_build_query',
    'title' => '生成 URL-encode 之后的请求字符串',
    'ret' => 'string',
    'prot' => 'string http_build_query(mixed $query_data, string $numeric_prefix, string $arg_separator, int $enc_type = PHP_QUERY_RFC1738)',
  ),
  'parse_url' => 
  array (
    'name' => 'parse_url',
    'title' => '解析 URL，返回其组成部分',
    'ret' => 'mixed',
    'prot' => 'mixed parse_url(string $url, int $component = -1)',
  ),
  'rawurldecode' => 
  array (
    'name' => 'rawurldecode',
    'title' => '对已编码的 URL 字符串进行解码',
    'ret' => 'string',
    'prot' => 'string rawurldecode(string $str)',
  ),
  'rawurlencode' => 
  array (
    'name' => 'rawurlencode',
    'title' => '按照 RFC 1738 对 URL 进行编码',
    'ret' => 'string',
    'prot' => 'string rawurlencode(string $str)',
  ),
  'urldecode' => 
  array (
    'name' => 'urldecode',
    'title' => '解码已编码的 URL 字符串',
    'ret' => 'string',
    'prot' => 'string urldecode(string $str)',
  ),
  'urlencode' => 
  array (
    'name' => 'urlencode',
    'title' => '编码 URL 字符串',
    'ret' => 'string',
    'prot' => 'string urlencode(string $str)',
  ),
  'doubleval' => 
  array (
    'name' => 'doubleval',
    'title' => 'floatval 的别名',
    'ret' => 'string',
    'prot' => 'string doubleval(string $str)',
  ),
  'empty' => 
  array (
    'name' => 'empty',
    'title' => '检查一个变量是否为空',
    'ret' => 'bool',
    'prot' => 'bool empty(mixed $var)',
  ),
  'floatval' => 
  array (
    'name' => 'floatval',
    'title' => '获取变量的浮点值',
    'ret' => 'float',
    'prot' => 'float floatval(mixed $var)',
  ),
  'get_defined_vars' => 
  array (
    'name' => 'get_defined_vars',
    'title' => '返回由所有已定义变量所组成的数组',
    'ret' => 'array',
    'prot' => 'array get_defined_vars()',
  ),
  'get_resource_type' => 
  array (
    'name' => 'get_resource_type',
    'title' => '返回资源（resource）类型',
    'ret' => 'string',
    'prot' => 'string get_resource_type(resource $handle)',
  ),
  'gettype' => 
  array (
    'name' => 'gettype',
    'title' => '获取变量的类型',
    'ret' => 'string',
    'prot' => 'string gettype(mixed $var)',
  ),
  'import_request_variables' => 
  array (
    'name' => 'import_request_variables',
    'title' => '将 GET／POST／Cookie 变量导入到全局作用域中',
    'ret' => 'bool',
    'prot' => 'bool import_request_variables(string $types, string $prefix)',
  ),
  'intval' => 
  array (
    'name' => 'intval',
    'title' => '获取变量的整数值',
    'ret' => 'int',
    'prot' => 'int intval(mixed $var, int $base)',
  ),
  'is_array' => 
  array (
    'name' => 'is_array',
    'title' => '检测变量是否是数组',
    'ret' => 'bool',
    'prot' => 'bool is_array(mixed $var)',
  ),
  'is_bool' => 
  array (
    'name' => 'is_bool',
    'title' => '检测变量是否是布尔型',
    'ret' => 'bool',
    'prot' => 'bool is_bool(mixed $var)',
  ),
  'is_callable' => 
  array (
    'name' => 'is_callable',
    'title' => '检测参数是否为合法的可调用结构',
    'ret' => 'bool',
    'prot' => 'bool is_callable(callable $name, bool $syntax_only = false, stringcallable_name)',
  ),
  'is_double' => 
  array (
    'name' => 'is_double',
    'title' => 'is_float 的别名',
    'ret' => 'bool',
    'prot' => 'bool is_double(callable $name, bool $syntax_only = false, stringcallable_name)',
  ),
  'is_float' => 
  array (
    'name' => 'is_float',
    'title' => '检测变量是否是浮点型',
    'ret' => 'bool',
    'prot' => 'bool is_float(mixed $var)',
  ),
  'is_int' => 
  array (
    'name' => 'is_int',
    'title' => '检测变量是否是整数',
    'ret' => 'bool',
    'prot' => 'bool is_int(mixed $var)',
  ),
  'is_integer' => 
  array (
    'name' => 'is_integer',
    'title' => 'is_int 的别名',
    'ret' => 'bool',
    'prot' => 'bool is_integer(mixed $var)',
  ),
  'is_long' => 
  array (
    'name' => 'is_long',
    'title' => 'is_int 的别名',
    'ret' => 'bool',
    'prot' => 'bool is_long(mixed $var)',
  ),
  'is_null' => 
  array (
    'name' => 'is_null',
    'title' => '检测变量是否为 &null;',
    'ret' => 'bool',
    'prot' => 'bool is_null(mixed $var)',
  ),
  'is_numeric' => 
  array (
    'name' => 'is_numeric',
    'title' => '检测变量是否为数字或数字字符串',
    'ret' => 'bool',
    'prot' => 'bool is_numeric(mixed $var)',
  ),
  'is_object' => 
  array (
    'name' => 'is_object',
    'title' => '检测变量是否是一个对象',
    'ret' => 'bool',
    'prot' => 'bool is_object(mixed $var)',
  ),
  'is_real' => 
  array (
    'name' => 'is_real',
    'title' => 'is_float 的别名',
    'ret' => 'bool',
    'prot' => 'bool is_real(mixed $var)',
  ),
  'is_resource' => 
  array (
    'name' => 'is_resource',
    'title' => '检测变量是否为资源类型',
    'ret' => 'bool',
    'prot' => 'bool is_resource(mixed $var)',
  ),
  'is_scalar' => 
  array (
    'name' => 'is_scalar',
    'title' => '检测变量是否是一个标量',
    'ret' => 'bool',
    'prot' => 'bool is_scalar(mixed $var)',
  ),
  'is_string' => 
  array (
    'name' => 'is_string',
    'title' => '检测变量是否是字符串',
    'ret' => 'bool',
    'prot' => 'bool is_string(mixed $var)',
  ),
  'isset' => 
  array (
    'name' => 'isset',
    'title' => '检测变量是否设置',
    'ret' => 'bool',
    'prot' => 'bool isset(mixed $var, mixed $...)',
  ),
  'print_r' => 
  array (
    'name' => 'print_r',
    'title' => '打印关于变量的易于理解的信息。',
    'ret' => 'bool',
    'prot' => 'bool print_r(mixed $expression, bool $return)',
  ),
  'serialize' => 
  array (
    'name' => 'serialize',
    'title' => '产生一个可存储的值的表示',
    'ret' => 'string',
    'prot' => 'string serialize(mixed $value)',
  ),
  'settype' => 
  array (
    'name' => 'settype',
    'title' => '设置变量的类型',
    'ret' => 'bool',
    'prot' => 'bool settype(mixedvar, string $type)',
  ),
  'strval' => 
  array (
    'name' => 'strval',
    'title' => '获取变量的字符串值',
    'ret' => 'string',
    'prot' => 'string strval(mixed $var)',
  ),
  'unserialize' => 
  array (
    'name' => 'unserialize',
    'title' => '从已存储的表示中创建 PHP 的值',
    'ret' => 'mixed',
    'prot' => 'mixed unserialize(string $str)',
  ),
  'unset' => 
  array (
    'name' => 'unset',
    'title' => '释放给定的变量',
    'ret' => 'void',
    'prot' => 'void unset(mixed $var, mixed $...)',
  ),
  'var_dump' => 
  array (
    'name' => 'var_dump',
    'title' => '打印变量的相关信息',
    'ret' => 'void',
    'prot' => 'void var_dump(mixed $expression, mixed $...)',
  ),
  'var_export' => 
  array (
    'name' => 'var_export',
    'title' => '输出或返回一个变量的字符串表示',
    'ret' => 'mixed',
    'prot' => 'mixed var_export(mixed $expression, bool $return)',
  ),
  'w32api_deftype' => 
  array (
    'name' => 'w32api_deftype',
    'title' => '为 w32api_functions 函数定一个类型',
    'ret' => 'bool',
    'prot' => 'bool w32api_deftype(string $typename, string $member1_type, string $member1_name, string $..., string $...)',
  ),
  'w32api_init_dtype' => 
  array (
    'name' => 'w32api_init_dtype',
    'title' => '创建了一个数据类型的实例，并且将函数传入的值填入其中',
    'ret' => 'resource',
    'prot' => 'resource w32api_init_dtype(string $typename, mixed $value, mixed $...)',
  ),
  'w32api_invoke_function' => 
  array (
    'name' => 'w32api_invoke_function',
    'title' => '带有一个参数的执行一个函数，参数传递在函数名的后面',
    'ret' => 'mixed',
    'prot' => 'mixed w32api_invoke_function(string $funcname, mixed $argument, mixed $...)',
  ),
  'w32api_register_function' => 
  array (
    'name' => 'w32api_register_function',
    'title' => '从函数库中使用 PHP 注册一个函数 function_name',
    'ret' => 'bool',
    'prot' => 'bool w32api_register_function(string $library, string $function_name, string $return_type)',
  ),
  'w32api_set_call_method' => 
  array (
    'name' => 'w32api_set_call_method',
    'title' => '设置调用的方法',
    'ret' => 'void',
    'prot' => 'void w32api_set_call_method(int $method)',
  ),
  'xhprof_disable' => 
  array (
    'name' => 'xhprof_disable',
    'title' => '停止 xhprof 分析器',
    'ret' => 'array',
    'prot' => 'array xhprof_disable()',
  ),
  'xhprof_enable' => 
  array (
    'name' => 'xhprof_enable',
    'title' => '启动 xhprof 性能分析器',
    'ret' => 'void',
    'prot' => 'void xhprof_enable(int $flags = 0, array $options)',
  ),
  'xhprof_sample_disable' => 
  array (
    'name' => 'xhprof_sample_disable',
    'title' => '停止 xhprof 性能采样分析器',
    'ret' => 'array',
    'prot' => 'array xhprof_sample_disable()',
  ),
  'xhprof_sample_enable' => 
  array (
    'name' => 'xhprof_sample_enable',
    'title' => 'Description',
    'ret' => 'void',
    'prot' => 'void xhprof_sample_enable()',
  ),
  'utf8_decode' => 
  array (
    'name' => 'utf8_decode',
    'title' => '将用 UTF-8 方式编码的 ISO-8859-1 字符串转换成单字节的 ISO-8859-1 字符串。',
    'ret' => 'string',
    'prot' => 'string utf8_decode(string $data)',
  ),
  'utf8_encode' => 
  array (
    'name' => 'utf8_encode',
    'title' => '将 ISO-8859-1 编码的字符串转换为 UTF-8 编码',
    'ret' => 'string',
    'prot' => 'string utf8_encode(string $data)',
  ),
  'xml_error_string' => 
  array (
    'name' => 'xml_error_string',
    'title' => '获取 XML 解析器的错误字符串',
    'ret' => 'string',
    'prot' => 'string xml_error_string(int $code)',
  ),
  'xml_get_current_byte_index' => 
  array (
    'name' => 'xml_get_current_byte_index',
    'title' => '获取 XML 解析器的当前字节索引',
    'ret' => 'int',
    'prot' => 'int xml_get_current_byte_index(resource $parser)',
  ),
  'xml_get_current_column_number' => 
  array (
    'name' => 'xml_get_current_column_number',
    'title' => '获取 XML 解析器的当前列号',
    'ret' => 'int',
    'prot' => 'int xml_get_current_column_number(resource $parser)',
  ),
  'xml_get_current_line_number' => 
  array (
    'name' => 'xml_get_current_line_number',
    'title' => '获取 XML 解析器的当前行号',
    'ret' => 'int',
    'prot' => 'int xml_get_current_line_number(resource $parser)',
  ),
  'xml_get_error_code' => 
  array (
    'name' => 'xml_get_error_code',
    'title' => '获取 XML 解析器错误代码',
    'ret' => 'int',
    'prot' => 'int xml_get_error_code(resource $parser)',
  ),
  'xml_parse_into_struct' => 
  array (
    'name' => 'xml_parse_into_struct',
    'title' => '将 XML 数据解析到数组中',
    'ret' => 'int',
    'prot' => 'int xml_parse_into_struct(resource $parser, string $data, arrayvalues, arrayindex)',
  ),
  'xml_parse' => 
  array (
    'name' => 'xml_parse',
    'title' => '开始解析一个 XML 文档',
    'ret' => 'int',
    'prot' => 'int xml_parse(resource $parser, string $data, bool $is_final = false)',
  ),
  'xml_parser_create_ns' => 
  array (
    'name' => 'xml_parser_create_ns',
    'title' => '生成一个支持命名空间的 XML 解析器',
    'ret' => 'resource',
    'prot' => 'resource xml_parser_create_ns(string $encoding, string $sep)',
  ),
  'xml_parser_create' => 
  array (
    'name' => 'xml_parser_create',
    'title' => '建立一个 XML 解析器',
    'ret' => 'resource',
    'prot' => 'resource xml_parser_create(string $encoding)',
  ),
  'xml_parser_free' => 
  array (
    'name' => 'xml_parser_free',
    'title' => '释放指定的 XML 解析器',
    'ret' => 'bool',
    'prot' => 'bool xml_parser_free(resource $parser)',
  ),
  'xml_parser_get_option' => 
  array (
    'name' => 'xml_parser_get_option',
    'title' => '从 XML 解析器获取选项设置信息',
    'ret' => 'mixed',
    'prot' => 'mixed xml_parser_get_option(resource $parser, int $option)',
  ),
  'xml_parser_set_option' => 
  array (
    'name' => 'xml_parser_set_option',
    'title' => '为指定 XML 解析进行选项设置',
    'ret' => 'bool',
    'prot' => 'bool xml_parser_set_option(resource $parser, int $option, mixed $value)',
  ),
  'xml_set_character_data_handler' => 
  array (
    'name' => 'xml_set_character_data_handler',
    'title' => '建立字符数据处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_character_data_handler(resource $parser, callable $handler)',
  ),
  'xml_set_default_handler' => 
  array (
    'name' => 'xml_set_default_handler',
    'title' => '建立默认处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_default_handler(resource $parser, callable $handler)',
  ),
  'xml_set_element_handler' => 
  array (
    'name' => 'xml_set_element_handler',
    'title' => '建立起始和终止元素处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_element_handler(resource $parser, callable $start_element_handler, callable $end_element_handler)',
  ),
  'xml_set_end_namespace_decl_handler' => 
  array (
    'name' => 'xml_set_end_namespace_decl_handler',
    'title' => '建立终止命名空间声明处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_end_namespace_decl_handler(resource $parser, callable $handler)',
  ),
  'xml_set_external_entity_ref_handler' => 
  array (
    'name' => 'xml_set_external_entity_ref_handler',
    'title' => '建立外部实体指向处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_external_entity_ref_handler(resource $parser, callable $handler)',
  ),
  'xml_set_notation_decl_handler' => 
  array (
    'name' => 'xml_set_notation_decl_handler',
    'title' => '建立注释声明处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_notation_decl_handler(resource $parser, callable $handler)',
  ),
  'xml_set_object' => 
  array (
    'name' => 'xml_set_object',
    'title' => '在对象中使用 XML 解析器',
    'ret' => 'pool',
    'prot' => 'pool xml_set_object(resource $parser, objectobject)',
  ),
  'xml_set_processing_instruction_handler' => 
  array (
    'name' => 'xml_set_processing_instruction_handler',
    'title' => '建立处理指令（PI）处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_processing_instruction_handler(resource $parser, callable $handler)',
  ),
  'xml_set_start_namespace_decl_handler' => 
  array (
    'name' => 'xml_set_start_namespace_decl_handler',
    'title' => '建立起始命名空间声明处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_start_namespace_decl_handler(resource $parser, callable $handler)',
  ),
  'xml_set_unparsed_entity_decl_handler' => 
  array (
    'name' => 'xml_set_unparsed_entity_decl_handler',
    'title' => '建立未解析实体定义声明处理器',
    'ret' => 'bool',
    'prot' => 'bool xml_set_unparsed_entity_decl_handler(resource $parser, callable $handler)',
  ),
  'xmlrpc_decode_request' => 
  array (
    'name' => 'xmlrpc_decode_request',
    'title' => '将 XML 译码为 PHP 本身的类型',
    'ret' => 'mixed',
    'prot' => 'mixed xmlrpc_decode_request(string $xml, stringmethod, string $encoding)',
  ),
  'xmlrpc_decode' => 
  array (
    'name' => 'xmlrpc_decode',
    'title' => '将 XML 译码为 PHP 本身的类型',
    'ret' => 'mixed',
    'prot' => 'mixed xmlrpc_decode(string $xml, string $encoding = "iso-8859-1")',
  ),
  'xmlrpc_encode_request' => 
  array (
    'name' => 'xmlrpc_encode_request',
    'title' => '为 PHP 的值生成 XML',
    'ret' => 'string',
    'prot' => 'string xmlrpc_encode_request(string $method, mixed $params, array $output_options)',
  ),
  'xmlrpc_encode' => 
  array (
    'name' => 'xmlrpc_encode',
    'title' => '为 PHP 的值生成 XML',
    'ret' => 'string',
    'prot' => 'string xmlrpc_encode(mixed $value)',
  ),
  'xmlrpc_get_type' => 
  array (
    'name' => 'xmlrpc_get_type',
    'title' => '为 PHP 的值获取 xmlrpc 的类型',
    'ret' => 'string',
    'prot' => 'string xmlrpc_get_type(mixed $value)',
  ),
  'xmlrpc_parse_method_descriptions' => 
  array (
    'name' => 'xmlrpc_parse_method_descriptions',
    'title' => '将 XML 译码成方法描述的列表',
    'ret' => 'array',
    'prot' => 'array xmlrpc_parse_method_descriptions(string $xml)',
  ),
  'xmlrpc_server_add_introspection_data' => 
  array (
    'name' => 'xmlrpc_server_add_introspection_data',
    'title' => '添加自我描述的文档',
    'ret' => 'int',
    'prot' => 'int xmlrpc_server_add_introspection_data(resource $server, array $desc)',
  ),
  'xmlrpc_server_call_method' => 
  array (
    'name' => 'xmlrpc_server_call_method',
    'title' => '解析 XML 请求同时调用方法',
    'ret' => 'string',
    'prot' => 'string xmlrpc_server_call_method(resource $server, string $xml, mixed $user_data, array $output_options)',
  ),
  'xmlrpc_server_create' => 
  array (
    'name' => 'xmlrpc_server_create',
    'title' => '创建一个 xmlrpc 服务端',
    'ret' => 'resource',
    'prot' => 'resource xmlrpc_server_create()',
  ),
  'xmlrpc_server_destroy' => 
  array (
    'name' => 'xmlrpc_server_destroy',
    'title' => '销毁服务端资源',
    'ret' => 'int',
    'prot' => 'int xmlrpc_server_destroy(resource $server)',
  ),
  'xmlrpc_server_register_introspection_callback' => 
  array (
    'name' => 'xmlrpc_server_register_introspection_callback',
    'title' => '注册一个 PHP 函数用于生成文档',
    'ret' => 'bool',
    'prot' => 'bool xmlrpc_server_register_introspection_callback(resource $server, string $function)',
  ),
  'xmlrpc_server_register_method' => 
  array (
    'name' => 'xmlrpc_server_register_method',
    'title' => '注册一个 PHP 函数用于匹配 xmlrpc 方法名',
    'ret' => 'bool',
    'prot' => 'bool xmlrpc_server_register_method(resource $server, string $method_name, string $function)',
  ),
  'xmlrpc_set_type' => 
  array (
    'name' => 'xmlrpc_set_type',
    'title' => '为一个 PHP 字符串值设置 xmlrpc 的类型、base64 或日期时间',
    'ret' => 'bool',
    'prot' => 'bool xmlrpc_set_type(stringvalue, string $type)',
  ),
);