<?php

/**
 * Class Http
 */
class Http {

    /**
     * @param $url
     * @return array
     */
    public static function getJson($url)
    {
        return json_decode(Http::get($url), true) ?: array();
    }

    /**
     * @param $url
     * @return mixed
     */
    public static function get($url)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        return curl_exec($ch);
    }

    /**
     * @param $url
     * @param $data
     * @return mixed
     */
    public static function put($url, $data)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('X-HTTP-Method-Override: PUT', 'Content-type: application/json'));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        return curl_exec($ch);
    }
}