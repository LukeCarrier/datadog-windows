# https://docs.datadoghq.com/developers/metrics/
$DATADOG_WMI_COOKING_METRIC_TYPES = @{
    # Gauges
    # Measure of a particular thing over time (e.g. memory utilisation)
    PERF_COUNTER_COUNTER = "gauge";
    PERF_COUNTER_BULK_COUNT = "gauge";
    PERF_COUNTER_RAWCOUNT = "gauge";
    PERF_COUNTER_LARGE_RAWCOUNT = "gauge";

    # Rates
    # Value change since the last measurement
    #  = "RATE";

    # Counters
    # Counters.
    #  = "COUNT"
}

function ConvertToDatadogWmiCheck-WmiObject() {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [System.Management.ManagementObject] $Object
    )

    Write-Host "  - class: $($Object.__CLASS)"
    Write-Host "    metrics:"
    $Object.Properties | % {
        $cookingType = $_.Qualifiers | ? { $_.Name -eq "CookingType" }
        $counterType = $_.Qualifiers | ? { $_.Name -eq "CounterType" }
        if ($cookingType) {
            $metricType = $DATADOG_WMI_COOKING_METRIC_TYPES[$cookingType.Value]
        } elseif ($counterType) {
            throw "No CookingType -- can't help with CounterType ($($counterType.Value)) yet"
        } else {
            Write-Verbose "No CookingType nor CounterType for $($_.Name)"
            return
        }
        Write-Host "      - [$($_.Name), datadog.name, $($metricType)]"
    }
}

#Get-WmiObject -Query "select * from Win32_PerfFormattedData_PerfNet_Server" `
#        | ConvertToDatadogWmiCheck-WmiObject
