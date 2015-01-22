<?php

/**
 * Class Http
 */
class Http {

    /**
     * @param $url
     * @param null $http_code
     * @return array
     */
    public static function getJson($url, &$http_code = null)
    {
        return json_decode(Http::get($url, $http_code), true) ?: array();
    }

    /**
     * @param $url
     * @param null $http_code
     * @return mixed
     */
    public static function get($url, &$http_code = null)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $result = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        return $result;
    }

    /**
     * @param $url
     * @param $data
     * @param null $http_code
     * @return mixed
     */
    public static function put($url, $data, &$http_code = null)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('X-HTTP-Method-Override: PUT', 'Content-type: application/json'));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        $result = curl_exec($ch);
        $http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        return $result;
    }
}