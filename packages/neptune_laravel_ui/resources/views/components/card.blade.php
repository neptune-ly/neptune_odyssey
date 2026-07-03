{{--
    <x-neptune::card variant="elevated">…</x-neptune::card>
    variant: standard (default) | elevated | tonal | glass
    `glass` is the translucent material — approved surfaces only (nav, hero,
    auth, modals), never tables/forms.
--}}
@props(['variant' => null])

<npt-card @if($variant) variant="{{ $variant }}" @endif {{ $attributes }}>{{ $slot }}</npt-card>
