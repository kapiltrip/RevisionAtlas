$ErrorActionPreference = 'Continue'

$iverilog = (Get-Command iverilog -ErrorAction Stop).Source
$scratch = Join-Path ([System.IO.Path]::GetTempPath()) 'revisionatlas_axi_code_verify'
New-Item -ItemType Directory -Force -Path $scratch | Out-Null

$cases = @(
    @{
        Name = 'Lessons 007-010 handshake demo'
        Top = 'handshake'
        Sources = @(
            'Section 01 - Introduction to AXI\Lessons 007-010 - Valid Ready Handshake\demo\handshake.sv'
        )
    },
    @{
        Name = 'Lessons 020-022 AXIS master'
        Top = 'tb_axis_m'
        Sources = @(
            'Section 02 - AXI-Stream Interface Fundamentals\Lessons 020-022 - AXIS Master\rtl\axis_m.sv',
            'Section 02 - AXI-Stream Interface Fundamentals\Lessons 020-022 - AXIS Master\tb\tb_axis_m.sv'
        )
    },
    @{
        Name = 'Lessons 023-026 AXIS slave'
        Top = 'axis_s_tb'
        Sources = @(
            'Section 02 - AXI-Stream Interface Fundamentals\Lessons 023-026 - AXIS Slave\rtl\axis_s.sv',
            'Section 02 - AXI-Stream Interface Fundamentals\Lessons 023-026 - AXIS Slave\tb\axis_s_tb.sv'
        )
    },
    @{
        Name = 'Lessons 027-028 AXIS integration'
        Top = 'top_tb'
        Sources = @(
            'Section 02 - AXI-Stream Interface Fundamentals\Lessons 020-022 - AXIS Master\rtl\axis_m.sv',
            'Section 02 - AXI-Stream Interface Fundamentals\Lessons 023-026 - AXIS Slave\rtl\axis_s.sv',
            'Section 02 - AXI-Stream Interface Fundamentals\Lessons 027-028 - Master Slave Integration\rtl\top.sv',
            'Section 02 - AXI-Stream Interface Fundamentals\Lessons 027-028 - Master Slave Integration\tb\top_tb.sv'
        )
    },
    @{
        Name = 'Lessons 030-033 round-robin arbiter'
        Top = 'tb'
        Sources = @(
            'Section 03 - AXI-Stream IPs\Lessons 030-033 - Round Robin Arbiter\rtl\robin.sv',
            'Section 03 - AXI-Stream IPs\Lessons 030-033 - Round Robin Arbiter\tb\tb.sv'
        )
    },
    @{
        Name = 'Lessons 034-038 AXIS arbiter'
        Top = 'tb_axis_arb'
        Sources = @(
            'Section 03 - AXI-Stream IPs\Lessons 034-038 - AXIS Arbiter\rtl\axis_arb.sv',
            'Section 03 - AXI-Stream IPs\Lessons 034-038 - AXIS Arbiter\tb\tb_axis_arb.sv'
        )
    },
    @{
        Name = 'Lessons 039-042 AXIS FIFO'
        Top = 'axis_fifo_tb'
        Sources = @(
            'Section 03 - AXI-Stream IPs\Lessons 039-042 - AXIS FIFO\rtl\axis_fifo.sv',
            'Section 03 - AXI-Stream IPs\Lessons 039-042 - AXIS FIFO\tb\axis_fifo_tb.sv'
        )
    },
    @{
        Name = 'Lessons 043-044 alternate AXIS FIFO'
        Top = 'axis_fifo_tb'
        Sources = @(
            'Section 03 - AXI-Stream IPs\Lessons 043-044 - AXIS FIFO Alternate\rtl\axis_fifo.sv',
            'Section 03 - AXI-Stream IPs\Lessons 043-044 - AXIS FIFO Alternate\tb\axis_fifo_tb.sv'
        )
    },
    @{
        Name = 'Lessons 060-067 AXIL write-only'
        Top = 'tb'
        Sources = @(
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 060-067 - AXIL Write Only Master and Slave\rtl\m_axi.sv',
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 060-067 - AXIL Write Only Master and Slave\rtl\s_axi.sv',
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 060-067 - AXIL Write Only Master and Slave\tb\tb.sv'
        )
    },
    @{
        Name = 'Lessons 068-072 protocol-checker exercise'
        Top = 'p_axi_tb'
        ExpectedFailure = 'syntax error'
        Sources = @(
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 068-072 - AXI Protocol Checker\rtl\p_m_axi.sv',
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 068-072 - AXI Protocol Checker\rtl\p_s_axi.sv',
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 068-072 - AXI Protocol Checker\tb\p_axi_tb.sv'
        )
    },
    @{
        Name = 'Lessons 073-081 AXIL read-only'
        Top = 'tb'
        Sources = @(
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 073-081 - AXIL Read Only Master and Slave\rtl\p_m_axi.sv',
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 073-081 - AXIL Read Only Master and Slave\rtl\p_s_axi.sv',
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 073-081 - AXIL Read Only Master and Slave\rtl\top.sv',
            'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 073-081 - AXIL Read Only Master and Slave\tb\tb.sv'
        )
    },
    @{
        Name = 'Lessons 086-093 AXIL combined master'
        Top = 'tb_axilite_m'
        Sources = @(
            'Section 06 - AXI-Lite Combined Read and Write\Lessons 086-093 - AXIL Read Write Master\rtl\axilite_m.sv',
            'Section 06 - AXI-Lite Combined Read and Write\Lessons 086-093 - AXIL Read Write Master\tb\tb_axilite_m.sv'
        )
    },
    @{
        Name = 'Lessons 095-100 AXIL GPIO'
        Top = 'tb_axi_gpio_slave'
        ExpectedFailure = 'Unknown module type: axilite_m'
        Sources = @(
            'Section 07 - AXI-Lite GPIO\Lessons 095-100 - AXIL GPIO\rtl\axilite_s.sv',
            'Section 07 - AXI-Lite GPIO\Lessons 095-100 - AXIL GPIO\tb\tb_axi_gpio_slave.sv'
        )
    },
    @{
        Name = 'Lessons 103-112 AXI4 single-beat'
        Top = 'tb_connect_m_s'
        ExpectedFailure = 'Unknown module type: axi_protocol_checker_0'
        Sources = @(
            'Section 08 - AXI4 Single Beat\Lessons 103-112 - AXI4 Single Beat Master and Slave\rtl\axi_master.sv',
            'Section 08 - AXI4 Single Beat\Lessons 103-112 - AXI4 Single Beat Master and Slave\rtl\axi4_slave.sv',
            'Section 08 - AXI4 Single Beat\Lessons 103-112 - AXI4 Single Beat Master and Slave\rtl\connect_m_s.sv',
            'Section 08 - AXI4 Single Beat\Lessons 103-112 - AXI4 Single Beat Master and Slave\tb\tb_connect_m_s.sv'
        )
    },
    @{
        Name = 'Lessons 115-128 AXI4 bursts'
        Top = 'tb_connect_m_s'
        ExpectedFailure = 'Unknown module type: axi_protocol_checker_0'
        Sources = @(
            'Section 09 - AXI4 Burst Modes\Lessons 115-128 - AXI4 Burst Master and Slave\rtl\axi_master.sv',
            'Section 09 - AXI4 Burst Modes\Lessons 115-128 - AXI4 Burst Master and Slave\rtl\axi4_slave.sv',
            'Section 09 - AXI4 Burst Modes\Lessons 115-128 - AXI4 Burst Master and Slave\rtl\connect_m_s.sv',
            'Section 09 - AXI4 Burst Modes\Lessons 115-128 - AXI4 Burst Master and Slave\tb\tb_connect_m_s.sv'
        )
    }
)

$componentCases = @(
    @{
        Name = 'Lessons 068-071 protocol-checker manager RTL'
        Top = 'p_m_axi'
        Source = 'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 068-072 - AXI Protocol Checker\rtl\p_m_axi.sv'
    },
    @{
        Name = 'Lessons 068-071 protocol-checker subordinate RTL'
        Top = 'p_s_axi'
        Source = 'Section 05 - AXI-Lite Single Beat without Pipeline\Lessons 068-072 - AXI Protocol Checker\rtl\p_s_axi.sv'
    },
    @{
        Name = 'Lessons 095-100 GPIO subordinate RTL'
        Top = 'axilite_s'
        Source = 'Section 07 - AXI-Lite GPIO\Lessons 095-100 - AXIL GPIO\rtl\axilite_s.sv'
    },
    @{
        Name = 'Lessons 103-107 AXI4 manager RTL'
        Top = 'axi_master'
        Source = 'Section 08 - AXI4 Single Beat\Lessons 103-112 - AXI4 Single Beat Master and Slave\rtl\axi_master.sv'
    },
    @{
        Name = 'Lessons 108-110 AXI4 subordinate RTL'
        Top = 'axi4_slave'
        Source = 'Section 08 - AXI4 Single Beat\Lessons 103-112 - AXI4 Single Beat Master and Slave\rtl\axi4_slave.sv'
    },
    @{
        Name = 'Lessons 115-122 AXI4 burst manager RTL'
        Top = 'axi_master'
        Source = 'Section 09 - AXI4 Burst Modes\Lessons 115-128 - AXI4 Burst Master and Slave\rtl\axi_master.sv'
    },
    @{
        Name = 'Lessons 123-125 AXI4 burst subordinate RTL'
        Top = 'axi4_slave'
        Source = 'Section 09 - AXI4 Burst Modes\Lessons 115-128 - AXI4 Burst Master and Slave\rtl\axi4_slave.sv'
    }
)

$componentPassed = 0
$componentFailed = 0
Write-Output 'Independent RTL checks for course units whose supplied integration/TB is incomplete:'
foreach ($component in $componentCases) {
    $output = Join-Path $scratch (($component.Top + '-component-' + [guid]::NewGuid().ToString('N')) + '.vvp')
    $source = Join-Path $PSScriptRoot $component.Source
    $diagnostics = @(& $iverilog -g2012 -Wall -s $component.Top -o $output $source 2>&1)

    if ($LASTEXITCODE -eq 0) {
        Write-Output ("PASS  {0}" -f $component.Name)
        $diagnostics | ForEach-Object {
            Write-Output ("WARN  {0}" -f $_)
        }
        $componentPassed++
    } else {
        Write-Output ("FAIL  {0}" -f $component.Name)
        $diagnostics | ForEach-Object {
            Write-Output ("      {0}" -f $_)
        }
        $componentFailed++
    }
}
Write-Output ("Independent RTL checks: {0} pass, {1} unexpected failures." -f $componentPassed, $componentFailed)
Write-Output ''

$passed = 0
$expectedFailures = 0
$failed = 0
foreach ($case in $cases) {
    $output = Join-Path $scratch (($case.Top + '-' + [guid]::NewGuid().ToString('N')) + '.vvp')
    $absoluteSources = @(
        $case.Sources | ForEach-Object { Join-Path $PSScriptRoot $_ }
    )

    $diagnostics = @(& $iverilog -g2012 -Wall -s $case.Top -o $output @absoluteSources 2>&1)
    $compilerExit = $LASTEXITCODE
    $diagnosticText = ($diagnostics | Out-String).Trim()
    $expectedPattern = if ($case.ContainsKey('ExpectedFailure')) {
        $case.ExpectedFailure
    } else {
        $null
    }

    if ($compilerExit -eq 0) {
        Write-Output ("PASS  {0}" -f $case.Name)
        $passed++
    } elseif ($expectedPattern -and $diagnosticText -match $expectedPattern) {
        Write-Output ("XFAIL {0}" -f $case.Name)
        Write-Output ("      Expected course dependency/source issue: {0}" -f $expectedPattern)
        $expectedFailures++
    } else {
        Write-Output ("FAIL  {0}" -f $case.Name)
        if ($diagnosticText) {
            $diagnosticText -split "`r?`n" | ForEach-Object {
                Write-Output ("      {0}" -f $_)
            }
        }
        $failed++
    }
}

Write-Output ("Checked {0} course units: {1} pass, {2} expected source/dependency stops, {3} unexpected failures." -f $cases.Count, $passed, $expectedFailures, $failed)
if (($componentFailed -ne 0) -or ($failed -ne 0)) {
    exit 1
}

exit 0
