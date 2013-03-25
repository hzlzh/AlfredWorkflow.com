<?php

Class HaskellParser extends AutoSuggestParser {

    public $display_name = "Haskell";

    public $short_name = "haskell";

    public $icon = "icon.png";

    protected function addResults($arr) {
        foreach ($arr as $key => $val) {
            $title = $val->content;
            $url = "http://www.haskell.org/ghc/docs/7.6.2/html/libraries/".$val->href;
            //$description = strip_tags($val->html);
            $description = "";
            $this->addResult($url, $title, $description);

        }
    }



    public function update() {

        $data = file_get_contents("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22http%3A%2F%2Fwww.haskell.org%2Fghc%2Fdocs%2F7.6.2%2Fhtml%2Flibraries%2F%22%20and%0A%20%20%20%20%20%20xpath%3D'%2F%2Fdiv%5B%40id%3D%22module-list%22%5D%2F%2Fa'&format=json");

        $data = json_decode($data);
        $this->addResults($data->query->results->a);

        $this->save();
    }
}