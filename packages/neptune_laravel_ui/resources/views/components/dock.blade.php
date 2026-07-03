{{--
    <x-neptune::dock>
        <x-neptune::dock-item label="Home" active>…icon…</x-neptune::dock-item>
        <x-neptune::dock-item label="Transfer">…icon…</x-neptune::dock-item>
    </x-neptune::dock>
    A floating, glassy bottom navigation. Place it fixed at the bottom of
    your app shell.
--}}
<npt-dock {{ $attributes }}>{{ $slot }}</npt-dock>
