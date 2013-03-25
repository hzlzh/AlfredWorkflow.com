<?php

Class NodeParser extends AutoSuggestParser {

    public $display_name = "node";

    public $short_name = "node";

    public $icon = "icon.png";

    protected function addResults($arr) {
        foreach ($arr as $result) {

            $this->processResult($result);
        }
    }

    public function seoUrl($string) {
        //lower case everything
        $string = strtolower($string);
        //make alphaunermic
        $string = preg_replace("/[^a-z0-9_\s-]/", " ", $string);
        //Clean multiple dashes or whitespaces
        $string = preg_replace("/[\s-]+/", " ", $string);
        $string = trim($string);
        //Convert whitespaces and underscore to dash
        $string = preg_replace("/[\s_]/", "_", $string);

        $new_string = str_replace("__", "_", $string);
        while($new_string !== $string) {
            $s = $new_string;
            $new_string = str_replace("__", "_", $string);
            $string = $s;
        }

        return $new_string;
    }

    public function processResult($data) {
      //$data = (object) $data;

      if (isset($data->name)) {

          $url = "http://nodejs.org/api/all.html#all_".$this->seoUrl($data->textRaw);
          $title = $data->textRaw;
          $description = $data->desc;

          $this->addResult($url, $title, $description);

        }
      if (isset($data->globals)) {
        $this->addResults($data->globals);
      }

      if (isset($data->methods)) {
        $this->addResults($data->methods);
      }

      if (isset($data->miscs)) {
        $this->addResults($data->miscs);
      }

      if (isset($data->vars)) {
        $this->addResults($data->vars);
      }

      if (isset($data->modules)) {
        $this->addResults($data->modules);
      }
    }



    public function update() {

        $data = file_get_contents("http://nodejs.org/api/all.json");

        $data = json_decode($data);



        $this->processResult($data);


        $this->save();
    }
}