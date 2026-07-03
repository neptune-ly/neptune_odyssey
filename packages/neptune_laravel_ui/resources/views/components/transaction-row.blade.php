{{--
    <x-neptune::transaction-row title="Coffee" subtitle="Today · Card"
        amount="-4.50" currency="LYD" />
    Add `credit` for a positive/incoming transaction (renders in the success tint).
--}}
@props(['title' => null, 'subtitle' => null, 'amount' => null, 'currency' => null, 'credit' => false])

<npt-transaction-row
    @if($title) title="{{ $title }}" @endif
    @if($subtitle) subtitle="{{ $subtitle }}" @endif
    @if($amount) amount="{{ $amount }}" @endif
    @if($currency) currency="{{ $currency }}" @endif
    @if($credit) credit @endif
    {{ $attributes }}
></npt-transaction-row>
