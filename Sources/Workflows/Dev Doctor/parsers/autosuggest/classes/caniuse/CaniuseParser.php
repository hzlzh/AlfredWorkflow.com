<?php

Class CaniuseParser extends AutoSuggestParser {

    public $display_name = "caniuse";

    public $short_name = "caniuse";

    public $icon = "icon.png";

    protected function addResults($arr) {
        $canIUseFeatureURL = "http://caniuse.com/#feat=";

        foreach ($arr as $key => $val) {
            $title = $val->title;
            $url = $canIUseFeatureURL . $key;
            $description = $val->description;
            $this->addResult($url, $title, $description);
        }
    }

    public function update() {

        $data = json_decode(file_get_contents("https://raw.github.com/Fyrd/caniuse/master/data.json"));

        $this->addResults($data->data);

        $this->save();
    }
}