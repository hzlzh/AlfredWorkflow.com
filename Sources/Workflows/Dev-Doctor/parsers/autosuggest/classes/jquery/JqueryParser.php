<?php

Class JqueryParser extends AutoSuggestParser {

    public $display_name = "jQuery";

    public $short_name = "jquery";

    public $icon = "icon.png";

    protected function addResults($arr) {
        foreach ($arr as $key => $val) {
            $title = $val->title;
            $url = $val->url;
            $description = strip_tags(implode($val->sectionHTMLs, ""));
            $description = str_replace("\n\n", "", $description);
            $this->addResult($url, $title, $description);

        }
    }



    public function update() {

        $data = file_get_contents("http://dochub.io/data/jquery.json");

        $data = json_decode($data);
        $this->addResults($data);

        $this->save();
    }
}