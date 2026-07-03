{{-- <x-neptune::chip selected>Filter label</x-neptune::chip> --}}
@props(['selected' => false, 'variant' => null, 'disabled' => false])

<npt-chip
    @if($selected) selected @endif
    @if($variant) variant="{{ $variant }}" @endif
    @disabled($disabled)
    {{ $attributes }}
>{{ $slot }}</npt-chip>
