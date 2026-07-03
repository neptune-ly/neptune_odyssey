{{--
    <x-neptune::balance-card label="Available balance" amount="12,480.50"
        currency="LYD" account="•••• 4821" hero />
    `hero` enables the brand gradient surface (the dashboard balance hero).
--}}
@props(['label' => null, 'amount' => null, 'currency' => null, 'account' => null, 'hero' => false])

<npt-balance-card
    @if($label) label="{{ $label }}" @endif
    @if($amount) amount="{{ $amount }}" @endif
    @if($currency) currency="{{ $currency }}" @endif
    @if($account) account="{{ $account }}" @endif
    @if($hero) hero @endif
    {{ $attributes }}
></npt-balance-card>
