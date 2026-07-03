{{-- <x-neptune::switch label="Wi-Fi" :checked="$wifiEnabled" /> --}}
@props(['checked' => false, 'disabled' => false, 'label' => null])

<npt-switch
    @checked($checked)
    @disabled($disabled)
    @if($label) label="{{ $label }}" @endif
    {{ $attributes }}
></npt-switch>
