<?php

Class CParser extends AutoSuggestParser {

    public $display_name = "C";

    public $short_name = "c";

    public $icon = "icon.png";

    protected function addResults($arr) {
        foreach ($arr as $key => $val) {
            $title = $val->content;
            $url = "http://www.acm.uiuc.edu/webmonkeys/book/c_guide/".$val->href;
            //$description = strip_tags($val->html);
            $description = "";
            $this->addResult($url, $title, $description);
        }
    }

    public function update() {

        $data = file_get_contents("http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22http%3A%2F%2Fwww.acm.uiuc.edu%2Fwebmonkeys%2Fbook%2Fc_guide%2F%22%20and%0A%20%20%20%20%20%20xpath%3D'%2F%2Fa'&format=json");

        $data = json_decode($data->query->results->a);
        $this->addResults($data);

        $this->save();
    }
}