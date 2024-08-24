# Variables globales ISP
:global isp1 "ISP1";
:global isp2 "ISP2";
:global isp3 "ISP3";

# Variables globales prefijos de cada caso combinacion por ISP Activo
:global prefixAll "@CASO1 ALL";
:global prefixIsp1Isp2 "@CASO2 TELMEX & MEGA1";
:global prefixIsp1Isp3 "@CASO3 TELMEX & MEGA2";
:global prefixIsp2Isp3 "@CASO4 MEGA1 & MEGA2";
:global prefixIsp1 "@CASO5 TELMEX";
:global prefixIsp2 "@CASO6 MEGA1";
:global prefixIsp3 "@CASO7 MEGA2";

# Variables globales Ip de cada ISP
:global ipIsp1 "192.168.1.254";
:global ipIsp2 "192.168.0.1";
:global ipIsp3 "192.168.2.1";

# Variable global que identifica cual ISP esta arriba (online)
:global ispUp;

# Funcion que desactiva todas la reglas mangles segun el prefijo de todos los casos (combinaciones)
:global downAllMangles do={
    :global prefixAll;
    :global prefixIsp1Isp2;
    :global prefixIsp1Isp3;
    :global prefixIsp2Isp3;
    :global prefixIsp1;
    :global prefixIsp2;
    :global prefixIsp3;
    /ip firewall mangle disable [find comment~$prefixAll];
    /ip firewall mangle disable [find comment~$prefixIsp1Isp2];
    /ip firewall mangle disable [find comment~$prefixIsp1Isp3];
    /ip firewall mangle disable [find comment~$prefixIsp2Isp3];
    /ip firewall mangle disable [find comment~$prefixIsp1];
    /ip firewall mangle disable [find comment~$prefixIsp2];
    /ip firewall mangle disable [find comment~$prefixIsp3];
    :log info "Execute Function downAllMangles";
};

# Funcion que activa las reglas mangles segun el prefijo que se le pase por parametro $paramPrefixMangle
:global upMangles do={
    :local paramPrefixMangle $1;
    /ip firewall mangle enable [find comment~$paramPrefixMangle];
    :log info "Execute Function upMangles paramPrefixMangle = $paramPrefixMangle";
};

# Funcion que maneja la logica cuando un ISP regresa a estar activa (Online)
:global handleActionsWhenUpMangle do={
    :global prefixAll;
    :global prefixIsp1Isp2;
    :global prefixIsp1Isp3;
    :global prefixIsp2Isp3;
    :global prefixIsp1;
    :global prefixIsp2;
    :global prefixIsp3;

    :global downAllMangles;
    :global upMangles;
    :global ispUp;
    :global isp1;
    :global isp2;
    :global isp3;
    :global ipIsp1;
    :global ipIsp2;
    :global ipIsp3;

    :local isOnlineISP1 true;
    :local isOnlineISP2 true;
    :local isOnlineISP3 true;

    :log info "Handle Actions When Up $ispUp";

    :if ($ispUp != $isp1 && [/ping $ipIsp1 count=5] = 0) do={
        :set $isOnlineISP1 false;
    }
    :if ($ispUp != $isp2 && [/ping $ipIsp2 count=5] = 0) do={
        :set $isOnlineISP2 false;
    }
    :if ($ispUp != $isp3 && [/ping $ipIsp3 count=5] = 0) do={
        :set $isOnlineISP3 false;
    }

    :log info "isOnlineISP1 = $isOnlineISP1, isOnlineISP2 = $isOnlineISP2, isOnlineISP3 = $isOnlineISP3";
    
    $downAllMangles;

    :if ($ispUp = $isp1) do={
        :if ($isOnlineISP2 && $isOnlineISP3) do={
            $upMangles ("" . $prefixAll . "");
        }
        :if ($isOnlineISP2 && !$isOnlineISP3) do={
            $upMangles ("" . $prefixIsp1Isp2 . "");
        }
        :if (!$isOnlineISP2 && $isOnlineISP3) do={
            $upMangles ("" . $prefixIsp1Isp3 . "");
        }
        :if (!$isOnlineISP2 && !$isOnlineISP3) do={
            $upMangles ("" . $prefixIsp1 . "");
        }
    }
    :if ($ispUp = $isp2) do={
        :if ($isOnlineISP1 && $isOnlineISP3) do={
            $upMangles ("" . $prefixAll . "");
        }
        :if ($isOnlineISP1 && !$isOnlineISP3) do={
            $upMangles ("" . $prefixIsp1Isp2 . "");
        }
        :if (!$isOnlineISP1 && $isOnlineISP3) do={
            $upMangles ("" . $prefixIsp2Isp3 . "");
        }
        :if (!$isOnlineISP1 && !$isOnlineISP3) do={
            $upMangles ("" . $prefixIsp2 . "");
        }
    }
    :if ($ispUp = $isp3) do={
        :if ($isOnlineISP1 && $isOnlineISP2) do={
            $upMangles ("" . $prefixAll . "");
        }
        :if ($isOnlineISP1 && !$isOnlineISP2) do={
            $upMangles ("" . $prefixIsp1Isp3 . "");
        }
        :if (!$isOnlineISP1 && $isOnlineISP2) do={
            $upMangles ("" . $prefixIsp2Isp3 . "");
        }
        :if (!$isOnlineISP1 && !$isOnlineISP2) do={
            $upMangles ("" . $prefixIsp3 . "");
        }
    }
    :log info "End function handleActionsWhenUpMangle";

}

$handleActionsWhenUpMangle;