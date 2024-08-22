
import { LocationManager } from './LocationManager'
import Userbutton from './Userbutton'

export default function FloatingMenu() {
    return (
        <div className='fixed top-4 right-4 lg:right-36 z-50 flex items-center gap-2 bg-red-100 p-2 rounded-lg'>
            <LocationManager />
            <Userbutton />
        </div>

    )
}

