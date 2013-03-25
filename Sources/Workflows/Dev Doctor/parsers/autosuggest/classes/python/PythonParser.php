<?php

Class PythonParser extends AutoSuggestParser {

    public $display_name = "python";

    public $short_name = "python";

    public $icon = "icon.png";

    protected function addResults($arr) {
        foreach ($arr as $key => $val) {
            $title = $val->title;
            $url = $val->url;
            $description = $val->html;
            $this->addResult($url, $title, $description);

            foreach ($val->searchableItems as $res) {
                $this->addResult($url."#".$res->domId, $res->name, "");
            }
        }
    }

    public function update() {

        $data = file_get_contents("http://dochub.io/data/python.json");

        $data = json_decode($data);
        $this->addResults($data);

        $this->save();
    }
}