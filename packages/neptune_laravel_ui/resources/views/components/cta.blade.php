{{--
    <x-neptune::cta arrow>Get started</x-neptune::cta>
    The premium animated call-to-action — specular sheen sweep + nudging
    arrow (both reduced-motion safe). variant="tonal" for the secondary tone.
--}}
@props(['arrow' => false, 'variant' => null, 'disabled' => false])

<npt-cta
    @if($arrow) arrow @endif
    @if($variant) variant="{{ $variant }}" @endif
    @disabled($disabled)
    {{ $attributes }}
>{{ $slot }}</npt-cta>
