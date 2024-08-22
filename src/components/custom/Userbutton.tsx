
import useSignOut from 'react-auth-kit/hooks/useSignOut';
import { AlertCircle, LogOut } from 'lucide-react';
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuGroup,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { avatarImageUrl } from '@/lib/avatar';
import useIsAuthenticated from 'react-auth-kit/hooks/useIsAuthenticated';
import useAuthUser from 'react-auth-kit/hooks/useAuthUser';
import { User } from '@/types';
import { socket } from '@/lib/socket';
import { useInterface } from '@/store/interface';

const Userbutton = () => {
    const signOut = useSignOut();
    const auth = useAuthUser();
    const isAuthenticated = useIsAuthenticated();

    const { onOpen } = useInterface()

    const handleSignOut = () => {
        signOut();
    };

    if (!isAuthenticated) {
        return null;
    }

    return (
        <div className="fixed top-4 right-4 lg:right-36 z-50">
            <DropdownMenu>
                <DropdownMenuTrigger asChild>
                    <div
                        className={`cursor-pointer rounded-full w-8 h-8 sm:w-10 sm:h-10 lg:w-12 lg:h-12 bg-center bg-cover bg-no-repeat border ${socket.connected
                            ? 'border-green-500 border-2'
                            : 'border-purple-300'
                            }`}
                        style={{
                            backgroundImage: `url(${avatarImageUrl(auth as User)})`,
                        }}
                        aria-label="User menu"
                    />
                </DropdownMenuTrigger>
                <DropdownMenuContent className="w-fit">
                    <DropdownMenuGroup>
                        <DropdownMenuItem className='lg:hidden' onClick={() => onOpen("alertSheet")}>
                            <AlertCircle className="mr-2 h-4 w-4" />
                            <span>View alerts</span>
                        </DropdownMenuItem>
                        <DropdownMenuItem onClick={handleSignOut}>
                            <LogOut className="mr-2 h-4 w-4" />
                            <span>Log out</span>
                        </DropdownMenuItem>
                    </DropdownMenuGroup>
                </DropdownMenuContent>
            </DropdownMenu>
        </div>
    );
};

export default Userbutton;

