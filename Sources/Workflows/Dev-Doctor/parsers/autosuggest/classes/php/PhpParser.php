<?php

Class PhpParser extends AutoSuggestParser {

    public $display_name = "PHP";

    public $short_name = "php";

    public $icon = "icon.png";

    protected function addResults($arr) {
        foreach ($arr as $key => $val) {
            $title = $val->title;
            $url = $val->url;
            $description = strip_tags(implode($val->sectionHTMLs, ""));
            $this->addResult($url, $title, $description);

        }
    }



    public function update() {

        $data = file_get_contents("http://dochub.io/data/php-ext.json");

        $data = json_decode($data);
        $this->addResults($data);

        $this->save();
    }
}