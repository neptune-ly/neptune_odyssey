{{-- <x-neptune::badge tone="success">3</x-neptune::badge> — tone: primary|success|error|neutral --}}
@props(['tone' => 'primary'])

<npt-badge tone="{{ $tone }}" {{ $attributes }}>{{ $slot }}</npt-badge>
