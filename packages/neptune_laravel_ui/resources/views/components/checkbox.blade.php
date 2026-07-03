{{-- <x-neptune::checkbox :checked="$agreed">I agree to the terms</x-neptune::checkbox> --}}
@props(['checked' => false, 'indeterminate' => false, 'disabled' => false])

<npt-checkbox
    @checked($checked)
    @if($indeterminate) indeterminate @endif
    @disabled($disabled)
    {{ $attributes }}
>{{ $slot }}</npt-checkbox>
