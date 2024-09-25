:global ispUp;

:global prefixAllBalancer "@BALANCEO";
:global prefixPCC "PCC";
:global TEMX1 "TELMEX1";
:global TEMX2 "TELMEX2";
:global MEGA1 "MEGA1";
:global MEGA2 "MEGA2";

# TODO: Fill ip by gateway ip
:global ipISPS {
    "TELMEX1"="";
    "TELMEX2"="";
    "MEGA1"="";
    "MEGA2"="";
};

:global mbISPS {
    "TELMEX1"=200;
    "TELMEX2"=200;
    "MEGA1"=100;
    "MEGA2"=100;
};

:global commentsISPS {
    "TELMEX1"="$prefixAllBalancer | $TEMX1 $prefixPCC";
    "TELMEX2"="$prefixAllBalancer | $TEMX2 $prefixPCC";
    "MEGA1"="$prefixAllBalancer | $MEGA1 $prefixPCC";
    "MEGA2"="$prefixAllBalancer | $MEGA2 $prefixPCC";
};

:global arrayISPS [:toarray "$TEMX1,$TEMX2,$MEGA1,$MEGA2"];

:global getComunDivisor do={
    :local a $1;
    :local b $2;
    :while ($b != 0) do={
        :local temp $b;
        :set b ($a % $b);
        :set a $temp;
    }
    :return $a;
}
:global getMaxComunDivisor do={
    :global getComunDivisor;
    :local arr $1;
    :local size [:len $arr];
    :local result [:pick $arr 0];
    :if ($size = 1) do={
        :return $result;
    }
    :for i from=1 to=(size - 1) do={
        :set result [$getComunDivisor $result [:pick $arr $i]];
    }
    :return $result;
}
:global downAllMangles do={
    :global prefixAllBalancer;
    /ip firewall mangle disable [find comment~$prefixAllBalancer];
};
:global updateMangle do={
    :local prefixMangle $1;
    :local perConnectionClassifier $2;
    :local valuePccToSet "both-addresses-and-ports:$perConnectionClassifier";
    :log info "updateMangle => prefix=$prefixMangle, valuePccToSet=$valuePccToSet";
    /ip firewall mangle set [find comment=$prefixMangle] per-connection-classifier=$valuePccToSet;
    /ip firewall mangle enable [find comment=$prefixMangle];
};

:global handleActionsWhenUpMangle do={
    # :log info "Init handleActionsWhenUpMangle";

    :global ispUp;
    
    :global downAllMangles;
    :global updateMangle;
    :global getMaxComunDivisor;
    :global arrayISPS;
    
    :global ipISPS;
    :global mbISPS;
    :global commentsISPS;

    :local logStatus "";
    :local ispPrefixActives [:toarray ""];
    :local mbsIspActives [:toarray ""];

    :local countIspActive 0;

    :for i from=0 to=([:len $arrayISPS] - 1) do={
        :local isp [:pick $arrayISPS $i];
        :local online true;
        :local ip ($ipISPS->($isp));
        :local mb ($mbISPS->($isp));
        :if ($ispUp != $isp && [/ping $ip count=3] = 0) do={
            :set $online false;
        }
        :if ($online) do={
            :set ($ispPrefixActives->$countIspActive) $isp;
            :set ($mbsIspActives->$countIspActive) $mb;
            :set countIspActive ($countIspActive + 1);
        }
        :set $logStatus ($logStatus . "    $isp=" . $online);
    }

    :log info $logStatus;
    $downAllMangles;
    :if ([:len $ispPrefixActives] > 0) do={
        :local maxComunDivisor [$getMaxComunDivisor $mbsIspActives]
        :log info "maxComunDivisor = $maxComunDivisor";
        :local ispPackages [:toarray ""];
        :local sumPackagesAvailables 0;
        :for i from=0 to=([:len $ispPrefixActives] - 1) do={
            :local isp [:pick $ispPrefixActives $i];
            :local mb ($mbISPS->($isp));

            :local package ($mb / $maxComunDivisor);
            :set $sumPackagesAvailables ($sumPackagesAvailables + $package);
            :set ($ispPackages->$i) $package;
        }
        :log info "ispPackages = $ispPackages";
        :log info "sumPackagesAvailables = $sumPackagesAvailables";
        :local counter 0;
        :for i from=0 to=([:len $ispPrefixActives] - 1) do={
            :local isp [:pick $ispPrefixActives $i];
            :local comment ($commentsISPS->($isp));
            :local package [:pick $ispPackages $i];
            :for j from=1 to=($package) do={
                :local prefix "$comment$j";
                :local pcc "$sumPackagesAvailables/$counter";
                $updateMangle $prefix $pcc;
                :set $counter ($counter + 1);
            }
        }
    }
    
    :log info "End function handleActionsWhenUpMangle";

}

$handleActionsWhenUpMangle;