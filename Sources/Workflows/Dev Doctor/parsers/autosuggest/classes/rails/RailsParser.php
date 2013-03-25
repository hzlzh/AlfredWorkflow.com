<?php

Class RailsParser extends AutoSuggestParser {

    public $display_name = "rails";

    public $short_name = "rails";

    public $icon = "icon.png";

    protected $done = array();

    protected function addResults($arr) {
        foreach ($arr as $key => $val) {
            $title = $string.$val[0];
            $url = "http://api.rubyonrails.org/".$val[1];
            $description = "";
            if (strlen($title) > 0) {
                if (!isset($this->done[$title])) {
                    $this->addResult($url, $title, $description);
                    $this->done[$title] = $url;
                }
                $this->addResults($val[3], $title."::");
            } else {
                $this->addResults($val[3]);
            }

        }
    }


    public function update() {

        $data = file_get_contents("http://api.rubyonrails.org/panel/tree.js");
        $data = str_replace("var tree =", "", $data);
        $data = json_decode($data);
        $this->addResults($data);

        $this->save();
    }
}