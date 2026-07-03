{{--
    <x-neptune::button variant="filled">Save changes</x-neptune::button>
    variant: filled (default) | elevated | tonal | outlined | text
--}}
@props(['variant' => null, 'disabled' => false])

<npt-button
    @if($variant) variant="{{ $variant }}" @endif
    @disabled($disabled)
    {{ $attributes }}
>{{ $slot }}</npt-button>
