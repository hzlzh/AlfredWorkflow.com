<?php

Class CssParser extends AutoSuggestParser {

    public $display_name = "CSS";

    public $short_name = "css";

    public $icon = "icon.png";

    protected function addResults($data) {
        foreach ($data as $key => $val) {
            $title = $val->title;
            $url = $val->url;
            $description = strip_tags(implode($val->sectionHTMLs, ""));
            $description = str_replace("Summary\n","",$description);

            $this->addResult($url, $title, $description);
        }
    }

    public function update() {

        $data = file_get_contents("http://dochub.io/data/css-mdn.json");
        $data = json_decode($data);
        $this->addResults($data);

        $this->save();
    }
}