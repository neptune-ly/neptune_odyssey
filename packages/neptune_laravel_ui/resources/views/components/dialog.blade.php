{{--
    <x-neptune::dialog :open="$showConfirm" headline="Confirm transfer">
        Send 500 LYD to Sara N.?
        <x-slot:actions>
            <x-neptune::button variant="text" onclick="this.closest('npt-dialog').removeAttribute('open')">Cancel</x-neptune::button>
            <x-neptune::button>Confirm</x-neptune::button>
        </x-slot:actions>
    </x-neptune::dialog>
--}}
@props(['open' => false, 'headline' => null])

<npt-dialog
    @if($open) open @endif
    @if($headline) headline="{{ $headline }}" @endif
    {{ $attributes }}
>{{ $slot }}@isset($actions)<span slot="actions">{{ $actions }}</span>@endisset</npt-dialog>
