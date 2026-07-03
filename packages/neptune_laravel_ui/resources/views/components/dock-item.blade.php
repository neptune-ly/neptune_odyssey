@props(['label' => null, 'active' => false, 'disabled' => false])

<npt-dock-item
    @if($label) label="{{ $label }}" @endif
    @if($active) active @endif
    @disabled($disabled)
    {{ $attributes }}
>{{ $slot }}</npt-dock-item>
