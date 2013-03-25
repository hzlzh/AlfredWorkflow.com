<?php

Class ErlangParser extends AutoSuggestParser {

    public $display_name = "Erlang";

    public $short_name = "erlang";

    public $icon = "icon.png";

    protected function addResults($arr) {
        foreach ($arr as $key => $val) {
            $title = $val[2];

            $strs = explode(":", $val[2]);
            $str = $strs[0].".html";
            if (count($strs) > 1) {
                $str .= "#".$strs[1];
            }

            $url = "http://erldocs.com/R15B/".$val[1]."/".$str;
            //$description = strip_tags($val->html);
            $description = implode(" ", array($val[3]));
            $this->addResult($url, $title, $description);

        }
    }



    public function update() {

        $data = file_get_contents("http://erldocs.com/R15B/erldocs_index.js");
        $data = str_replace("var index =", "", $data);


        $data = str_replace(";","", $data);

        $data = str_replace("\"","", $data);
        $data = str_replace("\t","", $data);

        $data = str_replace("   ","", $data);

        $data = utf8_decode($data);

        $data = str_replace("'","\"", $data);
        $data = json_decode($data);
        $this->addResults($data);



        $this->save();
    }
}